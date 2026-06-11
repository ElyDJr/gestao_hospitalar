import 'package:sqflite/sqflite.dart';
import '/data/resources/database_provider.dart';

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

  Future<List<Map<String, dynamic>>> buscarPacientesParaMedico() async {
    final db = await DatabaseProvider.instance.database;
    return await db.rawQuery('''
      SELECT 
        p.id_prontuario, p.data_abertura, p.status_prontuario,
        pac.nome, pac.cpf,
        t.risco, t.queixa, t.pressao, t.temperatura,
        s.numero_sala,
        l.numero_leito
      FROM prontuario p
      JOIN paciente pac ON p.id_paciente = pac.id_paciente
      JOIN triagem t ON p.id_triagem = t.id_triagem
      LEFT JOIN sala s ON p.id_sala = s.id_sala
      LEFT JOIN internacao i ON p.id_prontuario = i.id_prontuario
      LEFT JOIN leito l ON i.id_leito = l.id_leito
      WHERE p.status_prontuario = 'ATIVO'
    ''');
  }

}