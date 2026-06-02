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
    _repository = GenericRepositoryImpl<Medico>(
      db: db,
      tableName: 'medico',
      fromMap: (map) => Medico.fromMap(map),
      toMap: (medico) => medico.toMap(),
    );

    _especialidadeRepo = GenericRepositoryImpl<Especialidade>(
      db: db,
      tableName: 'especialidade',
      fromMap: (map) => Especialidade.fromMap(map),
      toMap: (esp) => esp.toMap(),
    );
  }

  Future<void> carregarMedicos() async {
    _isLoading = true;
    notifyListeners();
    _medicos = await _repository.findAll();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> salvarMedicoComEspecialidade(Medico medico, String nomeDigitado) async {
    // 1. Pega todas as especialidades
    final especialidades = await _especialidadeRepo.findAll();
    
    // 2. Procura usando o nome correto (descricaoEspecialidade)
    Especialidade? espEncontrada;
    try {
      espEncontrada = especialidades.firstWhere(
        (e) => e.descricaoEspecialidade?.toLowerCase().trim() == nomeDigitado.toLowerCase().trim()
      );
    } catch (e) {
      espEncontrada = null;
    }

    int? idDaEspecialidade;

    // 3. Pega o ID ou cria uma nova com o campo descricaoEspecialidade
    if (espEncontrada != null) {
      idDaEspecialidade = espEncontrada.id;
    } else {
      idDaEspecialidade = await _especialidadeRepo.create(
        Especialidade(descricaoEspecialidade: nomeDigitado.trim()) // ✅ CORRIGIDO AQUI!
      );
    }

    // 4. Monta o Médico com o ID da especialidade
    final medicoProntoParaSalvar = Medico(
      id: medico.id,
      idEspecialidade: idDaEspecialidade,
      nome: medico.nome,
      telefone: medico.telefone,
      email: medico.email,
      crm: medico.crm,
      honorario: medico.honorario,
    );

    // 5. Salva o médico
    if (medicoProntoParaSalvar.id == null) {
      await _repository.create(medicoProntoParaSalvar);
    } else {
      await _repository.update(medicoProntoParaSalvar);
    }
    
    await carregarMedicos();
  }

  Future<void> deletarMedico(int id) async {
    await _repository.delete(id);
    await carregarMedicos();
  }
}