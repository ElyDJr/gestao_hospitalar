import 'package:flutter/foundation.dart';
import '../../data/resources/database_provider.dart';
import '../entities/leito.dart';

class LeitoService {
  // RF06, RN13, RN14: Buscar apenas leitos disponíveis
  Future<List<Leito>> listarLeitosDisponiveis() async {
    final db = await DatabaseProvider.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'leito',
      where: 'situacao = ?',
      whereArgs: ['VAGO'],
    );
    return List.generate(maps.length, (i) => Leito.fromMap(maps[i]));
    //return buscarLeitosDisponiveis();
  }

  Future<List<Map<String, dynamic>>> buscarMapaLeitos() async {
    final db = await DatabaseProvider.instance.database;
    
    return await db.rawQuery('''
      SELECT
        l.id_leito,
        l.numero AS numero_leito,
        a.nome_ala AS ala, a.andar AS andar, -- 🟢 CORRIGIDO: a.nome_ala
        l.situacao AS status_leito,
        i.id_internacao,
        p.id_prontuario, p.evolucao, p.risco_evasao, p.isolamento, p.data_abertura,
        pac.id_paciente, pac.nome, pac.cpf,
        t.id_triagem, t.pressao, t.temperatura, t.saturacao, t.frequencia_cardiaca, t.escala_dor, t.queixa, t.alergias
      FROM leito l
      LEFT JOIN internacao i ON l.id_leito = i.id_leito
      JOIN ala a ON l.id_ala = a.id_ala
      LEFT JOIN prontuario p ON i.id_prontuario = p.id_prontuario AND p.status_prontuario = 'ATIVO'
      LEFT JOIN paciente pac ON p.id_paciente = pac.id_paciente
      LEFT JOIN triagem t ON p.id_triagem = t.id_triagem
      ORDER BY l.numero
    ''');
  }

  Future<void> atualizarEvolucaoProntuario(int idProntuario, String novaEvolucao) async {
    final db = await DatabaseProvider.instance.database;
    await db.update(
      'prontuario',
      {'evolucao': novaEvolucao},
      where: 'id_prontuario = ?',
      whereArgs: [idProntuario],
    );
  }

  Future<void> cadastrarLeito(Leito leito) async {
    final db = await DatabaseProvider.instance.database;
    await db.insert('leito', leito.toMap());
  }

  Future<void> atualizarStatusLeito(int idLeito, String novaSituacao) async {
    final db = await DatabaseProvider.instance.database;
    await db.update(
      'leito',
      {'situacao': novaSituacao},
      where: 'id_leito = ?',
      whereArgs: [idLeito],
    );
  }

  Future<List<Leito>> buscarLeitosDisponiveis() async {
    final db = await DatabaseProvider.instance.database;
    final List<Map<String, dynamic>> res = await db.rawQuery('''
      SELECT l.*, a.nome_ala, a.andar 
      FROM leito l
      INNER JOIN ala a ON l.id_ala = a.id_ala
      WHERE l.situacao = 'VAGO'
    ''');

    return res.map((map) {
      // Usamos um print para debugar no console o que vem do banco
      debugPrint("Dados do Leito + Ala: $map");
      return Leito.fromMap(map);
    }).toList();
  }

  Future<List<Map<String, dynamic>>> listarExamesCatalogo() async {
    final db = await DatabaseProvider.instance.database;
    final List<Map<String, dynamic>> res = await db.query(
      'exame',
      orderBy: 'nome',
    );
    return res;
  }

  // =========================================================================
  // FUNÇÕES CORRIGIDAS: AGORA COM status_exame E id_medico
  // =========================================================================

  Future<List<Map<String, dynamic>>> listarExamesSolicitados(int idProntuario) async {
    final db = await DatabaseProvider.instance.database;
    
    // Corrigido para buscar 'status_exame' e renomear para 'status' para a tela continuar funcionando
    final List<Map<String, dynamic>> res = await db.rawQuery('''
      SELECT se.id_exame, e.nome, se.status_exame AS status 
      FROM solicitacao_exame se 
      JOIN exame e ON se.id_exame = e.id_exame 
      WHERE se.id_prontuario = ?
    ''', [idProntuario]);

    return res.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<void> solicitarNovoExame(int idProntuario, int idExame) async {
    final db = await DatabaseProvider.instance.database;
    
    // Inserção corrigida com os campos exigidos pela sua classe SolicitacaoExame
    await db.insert('solicitacao_exame', {
      'id_prontuario': idProntuario,
      'id_exame': idExame,
      'id_medico': 1, // ID do médico (ajuste conforme o usuário logado se necessário)
      'status_exame': 'SOLICITADO',
      'data_solicitacao': DateTime.now().toIso8601String(),
    });
  }
}
