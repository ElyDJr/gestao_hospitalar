import 'package:sqflite/sqflite.dart';

class HistoricoService {
  final Database db;
  HistoricoService(this.db);

  Future<List<Map<String, dynamic>>> listarHistoricoUnificado() async {
    // Unimos as duas tabelas garantindo que as colunas tenham o mesmo nome na saída
    final sql = '''
      SELECT 
        'CLINICO' as tipo, 
        id_log as id, 
        responsavel as usuario, 
        data_alteracao as data, 
        descricao as detalhes 
      FROM log_prontuario
      
      UNION ALL
      
      SELECT 
        'FINANCEIRO' as tipo, 
        id_auditoria as id, 
        auditor as usuario, 
        data_auditoria as data, 
        observacoes as detalhes 
      FROM auditoria
      
      ORDER BY data DESC
    ''';
    return await db.rawQuery(sql);
  }
}