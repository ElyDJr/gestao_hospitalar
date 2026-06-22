import 'package:sqflite/sqflite.dart';
import '../../data/resources/database_provider.dart';
import '../entities/sala.dart';

class SalaService {
  Future<Database> get db async => await DatabaseProvider.instance.database;

  Future<void> salvar(Sala sala) async {
    final database = await db;
    if (sala.id == null) {
      await database.insert('sala', sala.toMap());

    } else {
      await database.update('sala', sala.toMap(), 
          where: 'id_sala = ?', whereArgs: [sala.id]);
    }
  }

  

  Future<void> excluir(int id) async {
    final database = await db;
    await database.delete('sala', where: 'id_sala = ?', whereArgs: [id]);
  }

  Future<List<Sala>> listarTodas() async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query('sala');
    return maps.map((m) => Sala.fromMap(m)).toList();
  }

  Future<Database> _getDb() async {
    final db = await DatabaseProvider.instance.database;
    // Tabela simplificada: sem ala/andar
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sala (
        id_sala INTEGER PRIMARY KEY AUTOINCREMENT,
        nome_sala TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'LIVRE'
      )
    ''');
    return db;
  }

  Future<void> atualizarStatusSala(int idSala, String status) async {
    final db = await _getDb();
    await db.update(
      'sala',
      {'status': status},
      where: 'id_sala = ?',
      whereArgs: [idSala],
    );
  }
}