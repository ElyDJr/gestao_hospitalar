// lib/domain/services/paciente_service.dart
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../entities/paciente.dart';
import '../repository/entitie_repository.dart';
import '../../data/repositories/generic_repository_impl.dart';

class PacienteService extends ChangeNotifier {
  late final EntitieRepository<Paciente> _repository;
  
  List<Paciente> _pacientes = [];
  List<Paciente> get pacientes => _pacientes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  PacienteService(Database db) {
    _repository = GenericRepositoryImpl<Paciente>(
      db: db,
      tableName: 'paciente',
      fromMap: (map) => Paciente.fromMap(map),
      toMap: (paciente) => paciente.toMap(),
    );
  }

  Future<void> carregarPacientes() async {
    _isLoading = true;
    notifyListeners();

    final todos = await _repository.findAll();
    // ✅ O SEGREDO DO SOFT DELETE: A lista da tela só recebe quem está ATIVO
    _pacientes = todos.where((p) => p.ativo != 0).toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> salvarPaciente(Paciente paciente) async {
    if (paciente.id == null) {
      await _repository.create(paciente);
    } else {
      await _repository.update(paciente); // Se tiver ID, ele faz UPDATE
    }
    await carregarPacientes();
  }

  // ✅ NOVA FUNÇÃO: Substitui o "deletar" físico
  Future<void> arquivarPaciente(Paciente paciente) async {
    // Usa o copyWith para mudar APENAS o status para zero (arquivado)
    final pacienteArquivado = paciente.copyWith(ativo: 0);
    await salvarPaciente(pacienteArquivado);
  }
}