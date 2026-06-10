import 'package:sqflite/sqflite.dart';
import '../entities/prontuario.dart';

class ProntuarioService {
  final Database _db;

  ProntuarioService(this._db);

  // Busca prontuário pelo ID da triagem (que é como vinculamos o paciente)
  Future<Map<String, dynamic>?> buscarPorTriagem(int idTriagem) async {
    final resultado = await _db.query('prontuario', where: 'id_triagem = ?', whereArgs: [idTriagem]);
    return resultado.isNotEmpty ? resultado.first : null;
  }

  Future<void> salvar(Map<String, dynamic> dados) async {
    await _db.insert('prontuario', dados, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}