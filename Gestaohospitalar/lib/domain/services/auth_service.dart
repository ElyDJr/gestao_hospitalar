import 'package:sqflite/sqflite.dart';
import '../entities/medico.dart';

class AuthService {
  final Database _db;

  AuthService(this._db);

  // Retorna o Médico se encontrar, ou null se não encontrar
  Future<Medico?> autenticarMedico(String crm, String senha) async {
    // 1. Busca o médico pelo CRM
    final List<Map<String, dynamic>> resultado = await _db.query(
      'medico',
      where: 'crm = ?',
      whereArgs: [crm.trim()], // Garantimos que estamos buscando o CRM correto
    );

    if (resultado.isNotEmpty) {
      // 2. Valida a senha (aqui você pode adicionar hash no futuro)
      if (senha == '123456') { 
        return Medico.fromMap(resultado.first);
      }
    }
    return null; // CRM não encontrado ou senha errada
  }
}