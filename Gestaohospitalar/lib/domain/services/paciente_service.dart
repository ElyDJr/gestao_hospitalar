// lib/domain/services/paciente_service.dart
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../entities/paciente.dart';
import '../repository/entitie_repository.dart';
import '../../data/repositories/generic_repository_impl.dart';

// O "with ChangeNotifier" faz o seu Service conseguir atualizar as telas!
class PacienteService with ChangeNotifier {
  final EntitieRepository<Paciente> _pacienteRepository;

  List<Paciente> _pacientes = [];
  bool _isLoading = false;

  // Variáveis para a tela ler os dados seguros
  List<Paciente> get pacientes => _pacientes;
  bool get isLoading => _isLoading;

  // O construtor configura o repositório genérico uma única vez
  PacienteService(Database db)
      : _pacienteRepository = GenericRepositoryImpl<Paciente>(
          db: db,
          tableName: 'paciente',
          fromMap: Paciente.fromMap,
          toMap: (p) => p.toMap(),
        );

  // 1. BUSCAR DO BANCO
  Future<void> carregarPacientes() async {
    _isLoading = true;
    notifyListeners(); // Avisa a tela para mostrar o símbolo de "carregando"

    try {
      _pacientes = await _pacienteRepository.findAll();
    } catch (e) {
      debugPrint("Erro ao buscar pacientes: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); // Avisa a tela que os dados chegaram para ela desenhar a lista
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
    
    // Após salvar, busca a lista atualizada do banco automaticamente!
    await carregarPacientes(); 
  }

  // 3. EXCLUIR DO BANCO
  Future<void> deletarPaciente(int id) async {
    await _pacienteRepository.delete(id);
    await carregarPacientes(); // Atualiza a lista após deletar
  }
}