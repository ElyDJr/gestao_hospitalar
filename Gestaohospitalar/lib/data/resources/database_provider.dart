// lib/data/resources/database_provider.dart
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'config.dart';

class DatabaseProvider {
  static final DatabaseProvider instance = DatabaseProvider._init();
  
  Database? _database;
  Future<Database>? _databaseFuture; // 🟢 A trava que impede o carregamento infinito!

  DatabaseProvider._init();

  Future<Database> get database {
    if (_database != null) return Future.value(_database!);
    
    // Se ainda não existe, mas já começou a carregar, devolve a mesma promessa
    // Isto impede que o Flutter tente abrir o banco 2x ao mesmo tempo.
    _databaseFuture ??= _initDB().then((db) {
      _database = db;
      return db;
    });
    
    return _databaseFuture!;
  }

  Future<Database> _initDB() async {
    late DatabaseFactory factory;
    String finalPath;
    String dbName = 'db_internacao.db';

    if (kIsWeb) {
      factory = databaseFactoryFfiWeb; // Cria no navegador
      finalPath = dbName;
    } else {
      sqfliteFfiInit();
      factory = databaseFactoryFfi; // Cria no Windows

      // 🟢 REMOVIDO o dart:io. 
      // Usamos a função nativa do sqflite que descobre uma pasta segura no Windows
      final dbPath = await factory.getDatabasesPath();
      finalPath = join(dbPath, dbName);

      debugPrint('\n==================================================');
      debugPrint('🗄️ FICHEIRO DO BANCO DE DADOS CRIADO EM:');
      debugPrint(finalPath);
      debugPrint('==================================================\n');
    }

    // Abre ou cria o banco
    return await factory.openDatabase(
      finalPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          debugPrint("⚙️ Banco não encontrado. A criar tabelas...");
          await _create(db);

          debugPrint("📥 A inserir dados de teste...");
          await _insertMockData(db);
        },
      ),
    );
  }

  Future<void> _create(Database db) async {
    final scripts = Config.sql.split(';');
    for (var script in scripts) {
      if (script.trim().isNotEmpty) {
        await db.execute(script);
      }
    }
  }
  
  Future<void> _insertMockData(Database db) async {
    final scripts = Config.mockData.split(';');
    for (var script in scripts) {
      if (script.trim().isNotEmpty) {
        try {
          await db.execute(script);
        } catch (e) {
          debugPrint("❌ Erro ao inserir dado de teste: $e\nScript: $script");
        }
      }
    }
  }
}