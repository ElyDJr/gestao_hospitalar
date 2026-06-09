// lib/data/resources/database_provider.dart
import 'dart:io' as io; // 🟢 Importação segura (com alias) para o Windows
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
    String finalPath = 'db_internacao.db';

    // 1. Configura o motor do banco dependendo de onde está rodando
    if (kIsWeb) {
      factory =
          databaseFactoryFfiWeb; //pra caso for rodar em web, cria um banco em memória (salva em binario)
    } else {
      sqfliteFfiInit();
      factory = databaseFactoryFfi;

      // // Monta o caminho físico no Windows e imprime no terminal para você achar facilmente
      // final dbPath = await factory.getDatabasesPath();
      // path = join(dbPath, path);

      // 🟢 CORREÇÃO: Pegar a raiz do projeto (onde você está rodando o app)
      final currentDir = io.Directory.current.path;
      
      // Montar o caminho exato para a pasta .dart_tool
      final dartToolDir = io.Directory(join(currentDir, '.dart_tool'));

      // Garantir que a pasta .dart_tool exista (se rodar fora da IDE, ela é recriada)
      if (!await dartToolDir.exists()) {
        await dartToolDir.create(recursive: true);
      }

      // Define o caminho completo do banco de dados
      finalPath = join(dartToolDir.path, 'db_internacao.db');

      debugPrint('\n==================================================');
      debugPrint('🗄️ ARQUIVO DO BANCO DE DADOS (ABRA NO SEU GERENCIADOR):');
      debugPrint(finalPath);
      debugPrint('==================================================\n');
    }

    // 2. Abre o banco. Se não existir, ele cria automaticamente disparando o onCreate
    return await factory.openDatabase(
      finalPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          debugPrint(
              "⚙️ Banco não encontrado. Criando tabelas a partir do config.dart...");
          await _create(db);

          // 🟢 NOVA LINHA: Inserindo dados de teste logo após criar as tabelas
          debugPrint("📥 Inserindo dados de teste...");
          await _insertMockData(db);
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
