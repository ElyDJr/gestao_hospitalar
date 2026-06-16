import '../../data/resources/database_provider.dart';
import '../entities/escala_medica.dart';

class EscalaService {
  // Busca toda a agenda de um mês/ano específico
  Future<List<EscalaMedica>> buscarEscalaDoMes(int ano, int mes) async {
    final db = await DatabaseProvider.instance.database;
    
    // Formata o mês para ter sempre 2 dígitos (ex: 06)
    String mesFormatado = mes.toString().padLeft(2, '0');
    String buscaData = '$ano-$mesFormatado-%';

    final List<Map<String, dynamic>> res = await db.rawQuery('''
      SELECT e.*, m.nome as nome_medico 
      FROM escala_medica e
      INNER JOIN medico m ON e.id_medico = m.id_medico
      WHERE e.data_escala LIKE ?
      ORDER BY e.data_escala ASC, e.hora_inicio ASC
    ''', [buscaData]);

    return res.map((map) => EscalaMedica.fromMap(map)).toList();
  }

  // Cadastra um novo horário para o médico
  Future<void> cadastrarEscala(EscalaMedica escala) async {
    final db = await DatabaseProvider.instance.database;
    await db.insert('escala_medica', escala.toMap());
  }

  // 🟢 NOVO: Atualiza uma escala existente
  Future<void> atualizarEscala(EscalaMedica escala) async {
    final db = await DatabaseProvider.instance.database;
    await db.update(
      'escala_medica',
      escala.toMap(),
      where: 'id_escala = ?',
      whereArgs: [escala.id],
    );
  }

  // 🟢 NOVO: Exclui uma escala
  Future<void> excluirEscala(int id) async {
    final db = await DatabaseProvider.instance.database;
    await db.delete(
      'escala_medica',
      where: 'id_escala = ?',
      whereArgs: [id],
    );
  }
}