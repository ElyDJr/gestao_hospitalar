import '../../data/resources/database_provider.dart';

class MedicamentoService {
  
  // Busca todos os medicamentos que estão cadastrados no hospital
  Future<List<Map<String, dynamic>>> listarMedicamentosCatalogo() async {
    try {
      final db = await DatabaseProvider.instance.database;
      
      // Faz o INNER JOIN para pegar o nome que está no Almoxarifado 
      // junto com o princípio ativo que está na tabela Medicamento
      final List<Map<String, dynamic>> result = await db.rawQuery('''
        SELECT m.id_medicamento, a.nome, m.principio_ativo 
        FROM medicamento m
        INNER JOIN almoxarifado a ON m.id_almoxarifado = a.id_almoxarifado
        ORDER BY a.nome
      ''');
      
      return result.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      throw Exception("Erro ao buscar catálogo de medicamentos: $e");
    }
  }

  // Grava a prescrição feita pelo médico na tabela do banco de dados
  Future<void> prescreverMedicamento({
    required int idProntuario,
    required int idMedicamento,
    required int idMedico,
    required String dosagem,
    required String viaAplicacao,
    required String frequencia,
    String? observacao, // 🟢 Adicionado como opcional (pode ser nulo)
  }) async {
    try {
      final db = await DatabaseProvider.instance.database;
      
      await db.insert('prescricao', {
        'id_prontuario': idProntuario,
        'id_medicamento': idMedicamento,
        'id_medico': idMedico,
        'dosagem': dosagem,
        'aplicacao': viaAplicacao, 
        'horario': frequencia,
        'observacao': observacao, // 🟢 Gravando a observação no banco
      });
    } catch (e) {
      throw Exception("Erro ao salvar a prescrição no banco: $e");
    }
  }


  Future<List<Map<String, dynamic>>> listarPrescricoesPorProntuario(int idProntuario) async {
    try {
      final db = await DatabaseProvider.instance.database;
      
      // Busca os dados da prescrição juntando com o nome do almoxarifado
      final List<Map<String, dynamic>> result = await db.rawQuery('''
        SELECT p.id_prescricao, p.dosagem, p.aplicacao, p.horario, p.observacao, a.nome AS nome_medicamento
        FROM prescricao p
        INNER JOIN medicamento m ON p.id_medicamento = m.id_medicamento
        INNER JOIN almoxarifado a ON m.id_almoxarifado = a.id_almoxarifado
        WHERE p.id_prontuario = ?
        ORDER BY p.id_prescricao DESC
      ''', [idProntuario]);
      
      return result.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      throw Exception("Erro ao buscar histórico de prescrições: $e");
    }
  }
}