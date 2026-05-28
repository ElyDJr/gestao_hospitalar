// lib/data/repositories/generic_repository_impl.dart
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/entitie.dart';
import '../../domain/repository/entitie_repository.dart';

class GenericRepositoryImpl<T extends Entitie> implements EntitieRepository<T> {
  final Database db;
  final String tableName;
  
  // Funções tradutoras passadas pelo Controller
  final T Function(Map<String, dynamic> map) fromMap;
  final Map<String, dynamic> Function(T entity) toMap;

  GenericRepositoryImpl({
    required this.db,
    required this.tableName,
    required this.fromMap,
    required this.toMap,
  });

  // Função auxiliar inteligente para mapear as PKs diferentes do seu script SQL
  String _getPrimaryKeyName() {
    if (tableName == 'interacao_medicamentosa') return 'id_interacao';
    if (tableName == 'solicitacao_exame') return 'id_solicitacao';
    if (tableName == 'consumo_item') return 'id_consumo';
    return 'id_$tableName'; // Padrão do seu banco: id_paciente, id_medico, id_leito, etc.
  }

  @override
  Future<int> create(T entity) async {
    return await db.insert(
      tableName,
      toMap(entity),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<int> update(T entity) async {
    if (entity.id == null) {
      throw Exception("Não é possível atualizar uma entidade sem ID.");
    }
    return await db.update(
      tableName,
      toMap(entity),
      where: '${_getPrimaryKeyName()} = ?',
      whereArgs: [entity.id],
    );
  }

  @override
  Future<int> delete(int id) async {
    return await db.delete(
      tableName,
      where: '${_getPrimaryKeyName()} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<T>> findAll() async {
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return maps.map((map) => fromMap(map)).toList();
  }
}