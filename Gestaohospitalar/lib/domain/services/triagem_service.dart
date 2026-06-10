// lib/domain/services/triagem_service.dart
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../entities/triagem.dart';
import '../repository/entitie_repository.dart';
import '../../data/repositories/generic_repository_impl.dart';
import '../../data/resources/database_provider.dart';



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

  // Adicione ao TriagemService
  Future<List<Map<String, dynamic>>> buscarFilaTriagem() async {
    final db = await DatabaseProvider.instance.database;
    
    // Consulta unindo as duas tabelas
    // Filtramos por pacientes que ainda não foram internados (assumindo que 'internacao' na triagem é NULL ou 'NAO')
    return await db.rawQuery('''
      SELECT t.*, p.nome, p.cpf 
      FROM triagem t
      JOIN paciente p ON t.id_paciente = p.id_paciente
      WHERE t.internacao IS NULL OR t.internacao = 'NAO'
      ORDER BY CASE t.risco 
        WHEN 'VERMELHO' THEN 1 
        WHEN 'LARANJA' THEN 2 
        WHEN 'AMARELO' THEN 3 
        WHEN 'VERDE' THEN 4 
        WHEN 'AZUL' THEN 5 
        ELSE 6 END
      ''');
  }

  // Busca fila de quem precisa de leito (Aguardando Alocação)
  Future<List<Map<String, dynamic>>> buscarFilaAguardandoAlocacao() async {
    final db = await DatabaseProvider.instance.database;
    return await db.rawQuery('''
      SELECT t.*, p.nome FROM triagem t
      JOIN paciente p ON t.id_paciente = p.id_paciente
      WHERE t.internacao = 'SIM' 
      AND t.id_triagem NOT IN (SELECT id_triagem FROM internacao)
    ''');
    //voltar aqui se eu precisar alterar de triagem pra prontuario
  }

}