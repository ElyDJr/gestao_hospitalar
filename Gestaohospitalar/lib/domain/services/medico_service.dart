// lib/domain/services/medico_service.dart
import 'package:flutter/foundation.dart';
import '../entities/medico.dart';

class MedicoService extends ChangeNotifier {
  final dynamic database;

  MedicoService(this.database);

  List<Medico> _medicos = [];
  List<Medico> get medicos => _medicos;

  /// Carrega os médicos do banco de dados (usado no Dashboard/initState)
  Future<void> carregarMedicos() async {
    try {
      // Exemplo com sqflite:
      // final resultado = await database.query('medicos', where: 'ativo = ?', whereArgs: [1]);
      // _medicos = resultado.map((map) => Medico.fromMap(map)).toList();
      
      _medicos = []; // Vazio por enquanto
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar médicos: $e');
    }
  }

  /// Método exigido por telas de listagem que chamam .listarMedicos()
  Future<List<Medico>> listarMedicos() async {
    // Se você já carrega na lista interna, pode retornar ela diretamente
    if (_medicos.isEmpty) {
      await carregarMedicos();
    }
    return _medicos;
  }

  /// Salva um novo médico ou atualiza um existente
  Future<void> salvarMedicoComEspecialidade(Medico medico, String especialidade) async {
    try {
      if (medico.id == null) {
        // Lógica de inserção usando `database`
      } else {
        // Lógica de atualização usando `database`
      }
      await carregarMedicos(); // Atualiza a lista e notifica os ouvintes
    } catch (e) {
      throw Exception('Erro ao salvar médico: $e');
    }
  }

  /// Arquiva (soft delete) o médico
  Future<void> arquivarMedico(Medico medico) async {
    try {
      if (medico.id == null) return;
      // Lógica de desativação usando `database`
      
      await carregarMedicos(); // Atualiza a lista e notifica os ouvintes
    } catch (e) {
      throw Exception('Erro ao arquivar médico: $e');
    }
  }
}