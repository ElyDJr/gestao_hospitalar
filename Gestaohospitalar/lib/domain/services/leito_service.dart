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

  // Atualizar a situação do leito (ex: para 'OCUPADO' após internar)
  Future<void> atualizarStatusLeito(int idLeito, String novaSituacao) async {
    final db = await DatabaseProvider.instance.database;
    await db.update(
      'leito',
      {'situacao': novaSituacao},
      where: 'id_leito = ?',
      whereArgs: [idLeito],
    );
  }
}