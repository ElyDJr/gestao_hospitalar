import 'package:sqflite/sqflite.dart';
import '../../data/resources/database_provider.dart';
import '../entities/internacao.dart';

class InternacaoService {
  Future<int> registrarInternacao(Internacao internacao) async {
    final db = await DatabaseProvider.instance.database;
    return await db.insert(
      'internacoes',
      internacao.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}