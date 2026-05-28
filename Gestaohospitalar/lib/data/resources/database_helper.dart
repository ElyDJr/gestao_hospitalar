// lib/data/datasources/database_helper.dart
// lib/data/resources/database_helper.dart
import 'package:flutter/services.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// Se o de cima der erro, remova a linha de baixo e use apenas o import acima:
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    // 1. Ativa o driver do SQLite para rodar dentro do ambiente Web
    var databaseFactory = databaseFactoryFfiWeb;
    final String path = 'db_internacao.db';

    try {
      // Tenta abrir o banco que já está salvo no cache do navegador
      return await databaseFactory.openDatabase(path);
    } catch (e) {
      // Se for a primeira vez que abre o app no PC, ele lê o seu arquivo pronto dos assets
      final ByteData data = await rootBundle.load('assets/database/db_internacao.db');
      final List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      
      // Copia a estrutura do seu banco para a memória virtual do navegador
      await databaseFactory.writeDatabaseBytes(path, Uint8List.fromList(bytes));
      
      // Abre o banco pronto para receber INSERTS, UPDATES e DELETES
      return await databaseFactory.openDatabase(path);
    }
  }
}