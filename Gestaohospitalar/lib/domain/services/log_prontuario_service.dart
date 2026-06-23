import 'package:sqflite/sqflite.dart';
import '../entities/log_prontuario.dart';

class LogProntuarioService {
  final Database db;
  LogProntuarioService(this.db);

  Future<void> registrar(int idProntuario, String usuario, String desc) async {
    await db.insert('log_prontuario', {
      'id_prontuario': idProntuario,
      'responsavel': usuario,
      'descricao': desc,
    });
  }

  Future<List<LogProntuario>> listarPorProntuario(int idProntuario) async {
    final res = await db.query('log_prontuario', where: 'id_prontuario = ?', whereArgs: [idProntuario]);
    return res.map((e) => LogProntuario.fromMap(e)).toList();
  }
}