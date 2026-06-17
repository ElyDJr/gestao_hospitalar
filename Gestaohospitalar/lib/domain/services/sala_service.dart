import 'package:sqflite/sqflite.dart';
import '/data/resources/database_provider.dart';

class SalaStatus {
  static const disponivel = 'DISPONIVEL';
  static const ocupado = 'OCUPADO';
  static const higienizacao = 'HIGIENIZACAO';
}

class SalaService {
  // 🟢 Construtor limpo (Sem a obrigatoriedade de passar o _db por parâmetro)
  SalaService();

  // 🟢 Método modificado para criar a tabela localmente apenas se ela não existir
  Future<Database> _getDb() async {
    final db = await DatabaseProvider.instance.database;
    
    // 🛡️ Garante que seu front-end funcione sem depender do back-end criar a tabela agora
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sala (
        id_sala INTEGER PRIMARY KEY AUTOINCREMENT,
        numero_sala TEXT NOT NULL,
        ala TEXT NOT NULL,
        andar TEXT NOT NULL,
        status_sala TEXT NOT NULL
      )
    ''');
    
    return db;
  }

  /// 🟢 Mapa de salas (sem JOIN desnecessário)
  Future<List<Map<String, dynamic>>> buscarMapaSalas() async {
    final db = await _getDb();
    return await db.rawQuery('''
      SELECT
        s.id_sala,
        s.numero_sala,
        s.ala,
        s.andar,
        s.status_sala
      FROM sala s
      ORDER BY s.numero_sala
    ''');
  }

  /// 🟢 Cadastro de sala
  Future<void> cadastrarSala(Map<String, dynamic> sala) async {
    final db = await _getDb();
    await db.insert(
      'sala',
      sala,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 🟢 Atualizar status da sala
  Future<void> atualizarStatusSala(int idSala, String status) async {
    final db = await _getDb();
    await db.update(
      'sala',
      {'status_sala': status},
      where: 'id_sala = ?',
      whereArgs: [idSala],
    );
  }

  /// 🟢 Buscar sala por ID
  Future<Map<String, dynamic>?> buscarSalaPorId(int idSala) async {
    final db = await _getDb();
    final resultado = await db.query(
      'sala',
      where: 'id_sala = ?',
      whereArgs: [idSala],
    );

    return resultado.isNotEmpty ? resultado.first : null;
  }

  /// 🟢 Listar todas as salas
  Future<List<Map<String, dynamic>>> listarSalas() async {
    final db = await _getDb();
    return await db.query(
      'sala',
      orderBy: 'numero_sala',
    );
  }
}