import '../../data/resources/database_provider.dart';
import '../entities/leito.dart';

class LeitoService {
  // RF06, RN13, RN14: Buscar apenas leitos disponíveis
  Future<List<Leito>> listarLeitosDisponiveis() async {
    final db = await DatabaseProvider.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'leito', // Nome exato da tabela no seu SQL
      where: 'situacao = ?', // Nome correto da coluna
      whereArgs: ['VAGO'],   // Valor correto definido no SQL
    );
    return List.generate(maps.length, (i) => Leito.fromMap(maps[i]));
  }

  Future<List<Map<String, dynamic>>> buscarMapaLeitos() async {
    final db = await DatabaseProvider.instance.database;
    
    return await db.rawQuery('''
      SELECT 
        l.id_leito, 
        l.numero AS numero_leito,
        l.ala, l.andar, -- 🟢 ADICIONADO AQUI
        l.situacao AS status_leito, 
        i.id_internacao,
        p.id_prontuario, p.evolucao, p.risco_evasao, p.isolamento, p.data_abertura,
        pac.id_paciente, pac.nome, pac.cpf,
        t.id_triagem, t.pressao, t.temperatura, t.saturacao, t.frequencia_cardiaca, t.escala_dor, t.queixa, t.alergias
      FROM leito l
      LEFT JOIN internacao i ON l.id_leito = i.id_leito
      LEFT JOIN prontuario p ON i.id_prontuario = p.id_prontuario AND p.status_prontuario = 'ATIVO'
      LEFT JOIN paciente pac ON p.id_paciente = pac.id_paciente
      LEFT JOIN triagem t ON p.id_triagem = t.id_triagem
      ORDER BY l.numero
    ''');
  }

  // Função para salvar a evolução médica
  Future<void> atualizarEvolucaoProntuario(int idProntuario, String novaEvolucao) async {
    final db = await DatabaseProvider.instance.database;
    await db.update(
      'prontuario',
      {'evolucao': novaEvolucao},
      where: 'id_prontuario = ?',
      whereArgs: [idProntuario],
    );
  }

  Future<void> cadastrarLeito(Leito leito) async { //lembrar de rever a necessidade
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

  // 🟢 Retorna apenas os leitos desocupados para o formulário de encaminhamento
  Future<List<Leito>> buscarLeitosDisponiveis() async {
    final db = await DatabaseProvider.instance.database;
    final List<Map<String, dynamic>> res = await db.query(
      'leito',
      where: 'situacao = ?',
      whereArgs: ['VAGO'],
      orderBy: 'numero',
    );
    return res.map((map) => Leito.fromMap(map)).toList();
  }
}