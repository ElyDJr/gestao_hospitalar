// lib/domain/services/paciente_service.dart
import 'package:sqflite/sqflite.dart';
import '../entities/paciente.dart';
import '../repository/entitie_repository.dart';
import '../../data/repositories/generic_repository_impl.dart';

class PacienteService {
  final EntitieRepository<Paciente> _pacienteRepository;

  // O construtor recebe o banco de dados e configura o repositório genérico para "paciente"
  PacienteService(Database db)
      : _pacienteRepository = GenericRepositoryImpl<Paciente>(
          db: db,
          tableName: 'paciente',
          fromMap: Paciente.fromMap,
          toMap: (p) => p.toMap(),
        );

  // Busca todos os pacientes do banco para listar na tela
  Future<List<Paciente>> listarTodos() async {
    return await _pacienteRepository.findAll();
  }

  // Regra para salvar ou atualizar um paciente
  Future<void> salvarPaciente(Paciente paciente) async {
    // Exemplo de regra de negócio que você pode colocar no Service:
    if (paciente.nome == null || paciente.nome!.isEmpty) {
      throw Exception("O nome do paciente é obrigatório.");
    }

    if (paciente.id == null) {
      await _pacienteRepository.create(paciente);
    } else {
      await _pacienteRepository.update(paciente);
    }
  }

  // Deleta um paciente pelo ID
  Future<void> deletarPaciente(int id) async {
    await _pacienteRepository.delete(id);
  }
}