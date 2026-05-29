// lib/data/resources/database_provider.dart
import 'package:flutter/foundation.dart'; // Importante: Traz o kIsWeb (suporte para Web)
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'config.dart';

class DatabaseProvider {
  // 1. Criação do Singleton (para o main.dart conseguir acessar via .instance)
  static final DatabaseProvider instance = DatabaseProvider._init();
  Database? _database;

  DatabaseProvider._init();

  // 2. Getter assíncrono do banco de dados
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // 3. Inicialização inteligente (Web e Desktop)
  Future<Database> _initDB() async {
    late DatabaseFactory databaseFactory;

    if (kIsWeb) {
      // Usa o driver Web (IndexedDB)
      databaseFactory = databaseFactoryFfiWeb;
    } else {
      // Usa o driver Desktop (Windows/Mac/Linux)
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path = 'db_internacao.db';
    
    // Se não for web, salva no disco físico do PC
    if (!kIsWeb) {
      path = join(await databaseFactory.getDatabasesPath(), path);
    }

    // 4. Abre o banco e cria as tabelas se ele não existir
    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await _create(db);
        },
      ),
    );
  }

  // 5. Execução do Script SQL consertada
  Future<void> _create(Database db) async {
    // Separa a String gigante do config.dart pelo ponto e vírgula ';'
    final scripts = Config.sql.split(';');
    
    for (var script in scripts) {
      if (script.trim().isNotEmpty) {
        // Executa tabela por tabela individualmente
        await db.execute(script);
      }
    }
  }
}