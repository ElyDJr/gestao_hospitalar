// lib/domain/services/medico_service.dart
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../entities/medico.dart';
import '../entities/especialidade.dart';
import '../repository/entitie_repository.dart';
import '../../data/repositories/generic_repository_impl.dart';

class MedicoService extends ChangeNotifier {
  late final EntitieRepository<Medico> _repository;
  late final EntitieRepository<Especialidade> _especialidadeRepo;
  
  List<Medico> _medicos = [];
  List<Medico> get medicos => _medicos;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  MedicoService(Database db) {
    _repository = GenericRepositoryImpl<Medico>(db: db, tableName: 'medico', fromMap: (m) => Medico.fromMap(m), toMap: (m) => m.toMap());
    _especialidadeRepo = GenericRepositoryImpl<Especialidade>(db: db, tableName: 'especialidade', fromMap: (m) => Especialidade.fromMap(m), toMap: (e) => e.toMap());
  }

  Future<void> carregarMedicos() async {
    _isLoading = true;
    notifyListeners();
    final todos = await _repository.findAll();
    _medicos = todos.where((m) => m.ativo != 0).toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> salvarMedicoComEspecialidade(Medico medico, String descEsp) async {
    final especialidades = await _especialidadeRepo.findAll();
    Especialidade? esp = especialidades.cast<Especialidade?>().firstWhere(
      (e) => e!.descricaoEspecialidade?.toLowerCase().trim() == descEsp.toLowerCase().trim(),
      orElse: () => null,
    );

    int idEsp = esp?.id ?? await _especialidadeRepo.create(Especialidade(descricaoEspecialidade: descEsp.trim()));

    final medicoFinal = Medico(
      id: medico.id,
      ativo: medico.ativo,
      idEspecialidade: idEsp,
      nome: medico.nome,
      crm: medico.crm,
      telefone: medico.telefone,
      email: medico.email,
      honorario: medico.honorario,
    );

    medico.id == null ? await _repository.create(medicoFinal) : await _repository.update(medicoFinal);
    await carregarMedicos();
  }

  Future<void> arquivarMedico(Medico medico) async {
    await _repository.update(medico.copyWith(ativo: 0));
    await carregarMedicos();
  }
}