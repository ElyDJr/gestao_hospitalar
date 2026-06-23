import 'package:sqflite/sqflite.dart';
import '../entities/auditoria.dart';

class AuditoriaService {
  final Database db;
  AuditoriaService(this.db);

  Future<int> criar(Auditoria auditoria) async {
    return await db.insert('auditoria', auditoria.toMap());
  }
}