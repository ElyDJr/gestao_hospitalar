// lib/domain/services/paciente_service.dart
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../entities/paciente.dart';
import '../repository/entitie_repository.dart';
import '../../data/repositories/generic_repository_impl.dart';

class PacienteService with ChangeNotifier {
  final EntitieRepository<Paciente> _pacienteRepository;

  List<Paciente> _pacientes = [];
  bool _isLoading = false;

  List<Paciente> get pacientes => _pacientes;
  bool get isLoading => _isLoading;

  PacienteService(Database db)
      : _pacienteRepository = GenericRepositoryImpl<Paciente>(
          db: db,
          tableName: 'paciente',
          fromMap: Paciente.fromMap,
          toMap: (p) => p.toMap(),
        );

  // 1. BUSCAR DO BANCO (Filtrando os Ativos)
  Future<void> carregarPacientes() async {
    _isLoading = true;
    notifyListeners(); 

    try {
      final todos = await _pacienteRepository.findAll();
      // ✅ Soft Delete: Exibe apenas pacientes que NÃO estão arquivados (ativo != 0)
      _pacientes = todos.where((p) => p.ativo != 0).toList();
    } catch (e) {
      debugPrint("Erro ao buscar pacientes: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }

  // 2. SALVAR NO BANCO
  Future<void> salvarPaciente(Paciente paciente) async {
    if (paciente.nome == null || paciente.nome!.isEmpty) {
      throw Exception("O nome do paciente é obrigatório.");
    }

    if (paciente.id == null) {
      await _pacienteRepository.create(paciente);
    } else {
      await _pacienteRepository.update(paciente);
    }
    
    await carregarPacientes(); 
  }

  // 3. ARQUIVAR DO BANCO (Soft Delete)
  Future<void> arquivarPaciente(Paciente paciente) async {
    final pacienteArquivado = paciente.copyWith(ativo: 0);
    await _pacienteRepository.update(pacienteArquivado);
    await carregarPacientes();
  }

  // 4. EXCLUIR DEFINITIVO
  Future<void> deletarPaciente(int id) async {
    await _pacienteRepository.delete(id);
    await carregarPacientes(); 
  }
}