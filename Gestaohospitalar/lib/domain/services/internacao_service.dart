import 'package:sqflite/sqflite.dart';
import '../../data/resources/database_provider.dart';
import '../entities/internacao.dart';

class InternacaoService {
  Future<void> registrarInternacao(Internacao internacao) async {
    final db = await DatabaseProvider.instance.database;
    await db.insert(
      'internacoes',
      internacao.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // 2. Atualiza o status do leito diretamente via SQL (Garante que não quebrará por novas colunas)
    await db.rawUpdate(
      'UPDATE leito SET situacao = ? WHERE id_leito = ?',
      ['OCUPADO', internacao.idLeito],
    );

  }
}