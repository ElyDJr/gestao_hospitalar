// lib/domain/services/paciente_service.dart
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../entities/paciente.dart';
import '../repository/entitie_repository.dart';
import '../../data/repositories/generic_repository_impl.dart';

class PacienteService with ChangeNotifier {
  final EntitieRepository<Paciente> _pacienteRepository;
  final Database db; // ✅ Acesso direto ao banco para transações e queries customizadas

  List<Paciente> _pacientes = [];
  bool _isLoading = false;

  List<Paciente> get pacientes => _pacientes;
  bool get isLoading => _isLoading;

  PacienteService(this.db)
      : _pacienteRepository = GenericRepositoryImpl<Paciente>(
          db: db,
          tableName: 'paciente',
          fromMap: Paciente.fromMap,
          toMap: (p) => p.toMap(),
        );

  /// Carrega os pacientes ATIVOS (ativo != 0)
  Future<void> carregarPacientes() async {
    _isLoading = true;
    notifyListeners(); 
    try {
      final todos = await _pacienteRepository.findAll();
      _pacientes = todos.where((p) => p.ativo != 0).toList();
    } catch (e) {
      debugPrint("Erro ao buscar pacientes: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }

  /// Retorna lista de pacientes ativos
  Future<List<Paciente>> listarPacientes() async {
    await carregarPacientes();
    return _pacientes;
  }

  /// Retorna a lista de pacientes ARQUIVADOS (ativo == 0) para a Tela de Arquivados
  Future<List<Paciente>> listarPacientesArquivados() async {
    try {
      final todos = await _pacienteRepository.findAll();
      return todos.where((p) => p.ativo == 0).toList();
    } catch (e) {
      debugPrint("Erro ao buscar pacientes arquivados: $e");
      return [];
    }
  }

  /// Busca os dados do convênio caso o paciente já esteja vinculado (para Edição)
  Future<Map<String, dynamic>?> buscarVinculoConvenio(int idPaciente) async {
    final result = await db.query(
      'paciente_convenio',
      where: 'id_paciente = ? AND ativo = 1',
      whereArgs: [idPaciente],
      limit: 1,
    );
    if (result.isNotEmpty) return result.first;
    return null;
  }

  /// Salva ou atualiza paciente + convênio com transação
  Future<void> salvarPaciente(Paciente paciente, {int? idConvenio, String? numeroCarteira, DateTime? validade}) async {
    if (paciente.nome == null || paciente.nome!.isEmpty) {
      throw Exception("O nome do paciente é obrigatório.");
    }

    await db.transaction((txn) async {
      int idPaciente;

      // 1. Salva ou atualiza os dados na tabela Paciente
      if (paciente.id == null) {
        idPaciente = await txn.insert('paciente', paciente.toMap());
      } else {
        idPaciente = paciente.id!;
        await txn.update(
          'paciente',
          paciente.toMap(),
          where: 'id_paciente = ?',
          whereArgs: [idPaciente],
        );
      }

      // 2. Se um convênio foi selecionado no formulário, cria/atualiza o vínculo
      if (idConvenio != null) {
        final vinculoMap = {
          'id_paciente': idPaciente,
          'id_convenio': idConvenio,
          'numero_carteira': numeroCarteira,
          'validade': validade != null 
              ? "${validade.year}-${validade.month.toString().padLeft(2, '0')}-${validade.day.toString().padLeft(2, '0')}" 
              : null,
          'ativo': 1,
        };

        final existing = await txn.query(
          'paciente_convenio',
          where: 'id_paciente = ? AND ativo = 1',
          whereArgs: [idPaciente],
        );

        if (existing.isNotEmpty) {
           await txn.update(
             'paciente_convenio',
             vinculoMap,
             where: 'id_paciente = ?',
             whereArgs: [idPaciente],
           );
        } else {
           await txn.insert('paciente_convenio', vinculoMap);
        }
      } else {
        // Se desmarcar o convênio, inativa o vínculo antigo
        if (paciente.id != null) {
          await txn.update(
            'paciente_convenio',
            {'ativo': 0},
            where: 'id_paciente = ?',
            whereArgs: [paciente.id],
          );
        }
      }
    });

    await carregarPacientes(); 
  }

  /// Arquiva o paciente alterando 'ativo' para 0 diretamente na tabela
  Future<void> arquivarPaciente(Paciente paciente) async {
    if (paciente.id == null) return;

    try {
      await db.update(
        'paciente',
        {'ativo': 0},
        where: 'id_paciente = ?',
        whereArgs: [paciente.id],
      );
      await carregarPacientes();
    } catch (e) {
      debugPrint("Erro ao arquivar paciente: $e");
      rethrow;
    }
  }

  /// Restaura o paciente arquivado alterando 'ativo' para 1
  Future<void> restaurarPaciente(Paciente paciente) async {
    if (paciente.id == null) return;

    try {
      await db.update(
        'paciente',
        {'ativo': 1},
        where: 'id_paciente = ?',
        whereArgs: [paciente.id],
      );
      await carregarPacientes();
    } catch (e) {
      debugPrint("Erro ao restaurar paciente: $e");
      rethrow;
    }
  }

  /// Exclui o paciente permanentemente do banco
  Future<void> deletarPaciente(int id) async {
    try {
      await db.delete(
        'paciente',
        where: 'id_paciente = ?',
        whereArgs: [id],
      );
      await carregarPacientes();
    } catch (e) {
      debugPrint("Erro ao deletar paciente: $e");
      rethrow;
    }
  }
}