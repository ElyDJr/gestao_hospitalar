import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:gestaohospitalar01/data/resources/config.dart';

class DatabaseProvider {
  late Database _database;

  Database get database => _database;

  Future<void> open() async {
    sqfliteFfiInit();

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      databaseFactory = databaseFactoryFfi;
    }

    String path = join(await getDatabasesPath(), "db_internacao.db");

    bool databaseExists = await databaseFactory.databaseExists(path);

    if (!databaseExists) {
      _database = await openDatabase(path,
          version: 1, onCreate: (db, version) => _create(db, version));
    } else {
      _database = await openDatabase(path);
    }
  }

  Future<void> _create(Database db, int version) async {
    return db.execute(Config.sql);
  }
}
