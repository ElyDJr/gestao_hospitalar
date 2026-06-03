// lib/domain/services/triagem_service.dart
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../entities/triagem.dart';
import '../repository/entitie_repository.dart';
import '../../data/repositories/generic_repository_impl.dart';



class TriagemService with ChangeNotifier {
  final EntitieRepository<Triagem> _repository;
  final Database db; // O campo declarado

  // ✅ CORREÇÃO: Usamos 'this.db' no construtor para inicializar o campo automaticamente
  TriagemService(this.db)
      : _repository = GenericRepositoryImpl<Triagem>(
          db: db,
          tableName: 'triagem',
          fromMap: Triagem.fromMap,
          toMap: (t) => t.toMap(),
        );

  Future<void> salvarTriagem(Triagem triagem) async {
    if (triagem.id == null) {
      await _repository.create(triagem);
    } else {
      await _repository.update(triagem);
    }
    notifyListeners();
  }

  // Agora, como o 'db' está inicializado corretamente, o erro sumirá desta função:
  Future<Triagem?> buscarTriagemPorPaciente(int idPaciente) async {
    final result = await db.query( // Agora o 'db' é reconhecido!
      'triagem',
      where: 'id_paciente = ?',
      whereArgs: [idPaciente],
      orderBy: 'id_triagem DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      return Triagem.fromMap(result.first);
    }
    return null;
  }
}