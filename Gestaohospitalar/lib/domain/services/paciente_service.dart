// lib/domain/services/paciente_service.dart
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../entities/paciente.dart';
import '../repository/entitie_repository.dart';
import '../../data/repositories/generic_repository_impl.dart';

class PacienteService with ChangeNotifier {
  final EntitieRepository<Paciente> _pacienteRepository;
  final Database db; // ✅ Agora o service tem acesso direto ao banco para a transação

  List<Paciente> _pacientes = [];
  bool _isLoading = false;

  List<Paciente> get pacientes => _pacientes;
  bool get isLoading => _isLoading;

  PacienteService(this.db) // ✅ Atualizado
      : _pacienteRepository = GenericRepositoryImpl<Paciente>(
          db: db,
          tableName: 'paciente',
          fromMap: Paciente.fromMap,
          toMap: (p) => p.toMap(),
        );

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

  // ✅ Busca os dados do convênio caso o paciente já esteja vinculado (para a Edição)
  Future<Map<String, dynamic>?> buscarVinculoConvenio(int idPaciente) async {
    final result = await db.query('paciente_convenio', where: 'id_paciente = ? AND ativo = 1', whereArgs: [idPaciente], limit: 1);
    if (result.isNotEmpty) return result.first;
    return null;
  }

  // ✅ Função de Salvar aprimorada com TRANSAÇÃO (Salva Paciente + Convênio juntos)
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
        await txn.update('paciente', paciente.toMap(), where: 'id_paciente = ?', whereArgs: [idPaciente]);
      }

      // 2. Se um convênio foi selecionado no formulário, cria/atualiza o vínculo
      if (idConvenio != null) {
        final vinculoMap = {
          'id_paciente': idPaciente,
          'id_convenio': idConvenio,
          'numero_carteira': numeroCarteira,
          'validade': validade != null ? "${validade.year}-${validade.month.toString().padLeft(2, '0')}-${validade.day.toString().padLeft(2, '0')}" : null,
          'ativo': 1,
        };

        final existing = await txn.query('paciente_convenio', where: 'id_paciente = ? AND ativo = 1', whereArgs: [idPaciente]);
        if (existing.isNotEmpty) {
           await txn.update('paciente_convenio', vinculoMap, where: 'id_paciente = ?', whereArgs: [idPaciente]);
        } else {
           await txn.insert('paciente_convenio', vinculoMap);
        }
      } else {
        // Se a pessoa desmarcar o convênio, nós inativamos o vínculo antigo
        if (paciente.id != null) {
          await txn.update('paciente_convenio', {'ativo': 0}, where: 'id_paciente = ?', whereArgs: [paciente.id]);
        }
      }
    });

    await carregarPacientes(); 
  }

  Future<void> arquivarPaciente(Paciente paciente) async {
    final pacienteArquivado = paciente.copyWith(ativo: 0);
    await _pacienteRepository.update(pacienteArquivado);
    await carregarPacientes();
  }

  Future<void> deletarPaciente(int id) async {
    await _pacienteRepository.delete(id);
    await carregarPacientes(); 
  }
}