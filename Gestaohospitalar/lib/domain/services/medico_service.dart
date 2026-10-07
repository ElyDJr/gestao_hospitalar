// lib/domain/services/medico_service.dart
import 'package:flutter/foundation.dart';
import '../entities/medico.dart';

class MedicoService extends ChangeNotifier {
  final dynamic database;

  MedicoService(this.database);

  List<Medico> _medicos = [];
  List<Medico> get medicos => _medicos;

  /// Carrega apenas os médicos ATIVOS (ativo = 1) do banco de dados
  Future<void> carregarMedicos() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'medicos',
        where: 'ativo = ?',
        whereArgs: [1],
      );

      _medicos = maps.map((map) => Medico.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar médicos: $e');
    }
  }

  /// Método exigido por telas de listagem que chamam .listarMedicos()
  Future<List<Medico>> listarMedicos() async {
    await carregarMedicos();
    return _medicos;
  }

  /// Salva um novo médico ou atualiza um existente
  Future<void> salvarMedicoComEspecialidade(Medico medico, String especialidade) async {
    try {
      final mapMedico = medico.toMap();
      mapMedico['ativo'] = 1; // Garante que o médico seja criado como ativo

      if (medico.id == null) {
        await database.insert('medicos', mapMedico);
      } else {
        await database.update(
          'medicos',
          mapMedico,
          where: 'id = ?',
          whereArgs: [medico.id],
        );
      }
      await carregarMedicos(); // Atualiza a lista e notifica a tela
    } catch (e) {
      throw Exception('Erro ao salvar médico: $e');
    }
  }

  /// Arquiva (soft delete) o médico alterando o status 'ativo' para 0
  Future<void> arquivarMedico(Medico medico) async {
    try {
      if (medico.id == null) return;

      await database.update(
        'medicos',
        {'ativo': 0},
        where: 'id = ?',
        whereArgs: [medico.id],
      );

      await carregarMedicos(); // Atualiza a lista e notifica a tela
    } catch (e) {
      throw Exception('Erro ao arquivar médico: $e');
    }
  }

  /// Restaura o médico arquivado alterando o status 'ativo' para 1
  Future<void> restaurarMedico(Medico medico) async {
    try {
      if (medico.id == null) return;

      await database.update(
        'medicos',
        {'ativo': 1},
        where: 'id = ?',
        whereArgs: [medico.id],
      );

      await carregarMedicos(); // Atualiza a lista e notifica a tela
    } catch (e) {
      throw Exception('Erro ao restaurar médico: $e');
    }
  }

  /// Lista todos os médicos arquivados (ativo = 0)
  Future<List<Medico>> listarMedicosArquivados() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'medicos',
        where: 'ativo = ?',
        whereArgs: [0],
      );

      return maps.map((map) => Medico.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Erro ao carregar médicos arquivados: $e');
      return [];
    }
  }
}