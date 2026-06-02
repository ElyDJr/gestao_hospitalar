// lib/data/resources/database_provider.dart
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'config.dart';

class DatabaseProvider {
  static final DatabaseProvider instance = DatabaseProvider._init();
  Database? _database;

  DatabaseProvider._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!; //se já existe, retorna o banco
  }

  Future<Database> _initDB() async {
    late DatabaseFactory factory;
    String path = 'db_internacao.db';

    // 1. Configura o motor do banco dependendo de onde está rodando
    if (kIsWeb) {
      factory =
          databaseFactoryFfiWeb; //pra caso for rodar em web, cria um banco em memória (salva em binario)
    } else {
      sqfliteFfiInit();
      factory = databaseFactoryFfi;

      // Monta o caminho físico no Windows e imprime no terminal para você achar facilmente
      final dbPath = await factory.getDatabasesPath();
      path = join(dbPath, path);

      debugPrint('\n==================================================');
      debugPrint('🗄️ ARQUIVO DO BANCO DE DADOS (ABRA NO SEU GERENCIADOR):');
      debugPrint(path);
      debugPrint('==================================================\n');
    }

    // 2. Abre o banco. Se não existir, ele cria automaticamente disparando o onCreate
    return await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          debugPrint(
              "⚙️ Banco não encontrado. Criando tabelas a partir do config.dart...");
          await _create(db);
        },
        onOpen: (db) {
          debugPrint(
              "✅ Conexão com o banco de dados estabelecida com sucesso!");
        },
      ),
    );
  }

  // 3. Execução do Script SQL limpa e sem redundâncias
  Future<void> _create(Database db) async {
    final scripts = Config.sql.split(';');

    for (var script in scripts) {
      if (script.trim().isNotEmpty) {
        await db.execute(script);
      }
    }
  }
}
