import 'package:flutter/material.dart';
import '../../data/resources/database_provider.dart';
import '../entities/exame.dart';

class ExameService extends ChangeNotifier {
  List<Exame> exames = [];
  bool isLoading = false;

  // --- MÉTODOS DE CATÁLOGO DE EXAMES ---

  Future<void> carregarExames() async {
    isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseProvider.instance.database;
      final result = await db.query('exame', orderBy: 'nome');
      exames = result.map((e) => Exame.fromMap(e)).toList();
    } catch (e) {
      throw Exception("Erro ao buscar exames do banco: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> salvarExame(Exame exame) async {
    try {
      final db = await DatabaseProvider.instance.database;

      if (exame.id == null) {
        final idInserido = await db.insert('exame', exame.toMap());
        exame.id = idInserido;
        exames.add(exame); 
      } else {
        await db.update(
          'exame', 
          exame.toMap(), 
          where: 'id_exame = ?', 
          whereArgs: [exame.id]
        );
        final index = exames.indexWhere((e) => e.id == exame.id);
        if (index != -1) exames[index] = exame;
      }
      notifyListeners();
    } catch (e) {
      throw Exception("Erro ao salvar exame: $e");
    }
  }

  Future<void> arquivarExame(Exame exame) async {
    try {
      final db = await DatabaseProvider.instance.database;
      await db.delete('exame', where: 'id_exame = ?', whereArgs: [exame.id]);
      exames.removeWhere((e) => e.id == exame.id); 
      notifyListeners();
    } catch (e) {
      throw Exception("Erro ao excluir exame: $e");
    }
  }

  // --- MÉTODOS DE SOLICITAÇÃO ---

  // --- MÉTODOS DE SOLICITAÇÃO ---

  Future<List<Map<String, dynamic>>> buscarExamesPorProntuario(int idProntuario) async {
    try {
      final db = await DatabaseProvider.instance.database;
      // CORREÇÃO: Alterado de se.status para se.status_exame
      // Usamos "AS status" para não quebrar a sua interface (UI) caso ela espere essa chave
      final result = await db.rawQuery('''
        SELECT se.id_exame, e.nome, se.status_exame AS status 
        FROM solicitacao_exame se 
        JOIN exame e ON se.id_exame = e.id_exame 
        WHERE se.id_prontuario = ?
      ''', [idProntuario]);
      
      return result.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      throw Exception("Erro ao buscar histórico de exames: $e");
    }
  }

  Future<void> solicitarNovoExame({
    required int idProntuario,
    required int idExame,
    required int idMedico,
  }) async {
    try {
      final db = await DatabaseProvider.instance.database;
      
      // CORREÇÃO: O nome da coluna no banco é 'status_exame' e não 'status'
      await db.insert('solicitacao_exame', {
        'id_prontuario': idProntuario,
        'id_exame': idExame,
        'id_medico': idMedico, 
        'status_exame': 'SOLICITADO', 
      });
      // ADICIONE ESTA LINHA:
      notifyListeners(); // <--- Isso é o que faz a tela atualizar e mostrar o exame na lista!
    } catch (e) {
      throw Exception("Erro ao salvar solicitação de exame: $e");
    }
  }
}