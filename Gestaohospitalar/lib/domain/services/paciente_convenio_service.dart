// lib/domain/services/paciente_convenio_service.dart
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../entities/paciente_convenio.dart';
import '../../data/repositories/generic_repository_impl.dart';
import '../repository/entitie_repository.dart';

class PacienteConvenioService extends ChangeNotifier {
  late final EntitieRepository<PacienteConvenio> _repository;

  PacienteConvenioService(Database db) {
    _repository = GenericRepositoryImpl<PacienteConvenio>(
      db: db,
      tableName: 'paciente_convenio',
      fromMap: (map) => PacienteConvenio.fromMap(map),
      toMap: (pc) => pc.toMap(),
    );
  }

  Future<void> vincularConvenio(PacienteConvenio vinculo) async {
    // Se já existir um registro para esse paciente, poderíamos dar update, 
    // mas por enquanto vamos criar o registro de vínculo
    await _repository.create(vinculo);
    notifyListeners();
  }
  
  // Método para buscar convênio do paciente na tela de edição
  Future<PacienteConvenio?> buscarPorPaciente(int idPaciente) async {
    final todos = await _repository.findAll();
    return todos.cast<PacienteConvenio?>().firstWhere(
      (pc) => pc!.idPaciente == idPaciente && pc.ativo == true,
      orElse: () => null,
    );
  }
}