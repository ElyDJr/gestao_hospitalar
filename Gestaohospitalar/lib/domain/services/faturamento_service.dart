// import 'package:sqflite/sqflite.dart';
// import '../entities/faturamento.dart';
// import '../repository/entitie_repository.dart';
// import '../../data/repositories/generic_repository_impl.dart';

// class FaturamentoService {
//   final Database db;
//   late final EntitieRepository<Faturamento> _repository;

//   FaturamentoService(this.db) {
//     _repository = GenericRepositoryImpl<Faturamento>(
//       db: db,
//       tableName: 'faturamento',
//       fromMap: (map) => Faturamento.fromMap(map),
//       toMap: (f) => f.toMap(),
//     );
//   }

//   /// 1. Apenas faz os cálculos e retorna o mapa com os valores
//   Future<Map<String, dynamic>> calcularConta(int idProntuario, int? idInternacao) async {
//     // 1. Honorários Médicos
//     final med = await db.rawQuery('''
//       SELECT m.honorario FROM prontuario pr 
//       JOIN medico m ON pr.id_medico = m.id_medico 
//       WHERE pr.id_prontuario = ?''', [idProntuario]);
//     double valorHonorarios = (med.isNotEmpty) ? (med.first['honorario'] as num).toDouble() : 0.0;

//     // 2. Exames
//     final ex = await db.rawQuery('''
//       SELECT SUM(e.valor) as total FROM solicitacao_exame se 
//       JOIN exame e ON se.id_exame = e.id_exame 
//       WHERE se.id_prontuario = ?''', [idProntuario]);
//     double valorExames = (ex.first['total'] as num? ?? 0).toDouble();

//     // 3. Medicamentos/Consumo
//     double valorConsumo = 0;
//     if (idInternacao != null) {
//       final cons = await db.rawQuery('''
//         SELECT SUM(ci.quantidade * a.valor_unitario) as total 
//         FROM consumo_item ci 
//         JOIN almoxarifado a ON ci.id_almoxarifado = a.id_almoxarifado 
//         WHERE ci.id_internacao = ?''', [idInternacao]);
//       valorConsumo = (cons.first['total'] as num? ?? 0).toDouble();
//     }

//     // 4. Busca desconto do convênio
//     final conv = await db.rawQuery('''
//       SELECT c.percentual_cobertura FROM paciente_convenio pc 
//       JOIN convenio c ON pc.id_convenio = c.id_convenio 
//       JOIN prontuario pr ON pr.id_paciente = pc.id_paciente
//       WHERE pr.id_prontuario = ? AND pc.ativo = 1''', [idProntuario]);
    
//     double percentual = (conv.isNotEmpty) ? (conv.first['percentual_cobertura'] as num).toDouble() : 0.0;
//     double totalBruto = valorHonorarios + valorExames + valorConsumo;
//     double valorAbatido = totalBruto * (percentual / 100);

//     return {
//       'honorarios': valorHonorarios,
//       'exames': valorExames,
//       'consumo': valorConsumo,
//       'total_bruto': totalBruto,
//       'total_a_pagar': totalBruto - valorAbatido
//     };
//   }

//   /// 2. Chama o cálculo e SALVA no banco de dados
//   Future<void> gerarContaFinal(int idProntuario, int? idInternacao) async {
//     try {
//       print("Iniciando faturamento para Prontuário: $idProntuario");
      
//       final calc = await calcularConta(idProntuario, idInternacao);

//       Map<String, dynamic> dados = {
//         'id_prontuario': idProntuario,
//         'id_internacao': idInternacao,
//         'valor_medicamentos': calc['consumo'],
//         'valor_exames': calc['exames'],
//         'valor_internacao': (idInternacao != null ? 1500.0 : 0.0), // Ajuste sua lógica de diária aqui
//         'valor_honorarios': calc['honorarios'],
//         'valor_consumo': calc['consumo'],
//         'valor_total': calc['total_a_pagar'],
//         'status_pagamento': 'PENDENTE'
//       };

//       int result = await db.insert('faturamento', dados);
//       print("Faturamento salvo com sucesso, ID: $result");
//     } catch (e) {
//       print("ERRO AO FATURAR: $e");
//       rethrow;
//     }
//   }

//   // 3. Listagem para a tela de faturamento
//   Future<List<Map<String, dynamic>>> listarFaturamentosComPaciente() async {
//     final results = await db.rawQuery('''
//       SELECT f.*, p.nome as nome_paciente, p.cpf
//       FROM faturamento f
//       LEFT JOIN prontuario pr ON f.id_prontuario = pr.id_prontuario
//       LEFT JOIN paciente p ON pr.id_paciente = p.id_paciente
//       ORDER BY f.data_fechamento DESC
//     ''');
//     return results;
//   }

//   // 4. Marcar como pago e arquivar
//   Future<void> marcarComoPago(int idFaturamento, int idProntuario) async {
//     await db.transaction((txn) async {
//       await txn.update('faturamento', {'status_pagamento': 'PAGO'},
//           where: 'id_faturamento = ?', whereArgs: [idFaturamento]);
      
//       await txn.update('prontuario', {'status_prontuario': 'ARQUIVADO'},
//           where: 'id_prontuario = ?', whereArgs: [idProntuario]);
//     });
//   }
// }
import 'package:sqflite/sqflite.dart';
import '../entities/faturamento.dart';
import '../repository/entitie_repository.dart';
import '../../data/repositories/generic_repository_impl.dart';

class FaturamentoService {
  final Database db;
  late final EntitieRepository<Faturamento> _repository;

  FaturamentoService(this.db) {
    _repository = GenericRepositoryImpl<Faturamento>(
      db: db,
      tableName: 'faturamento',
      fromMap: (map) => Faturamento.fromMap(map),
      toMap: (f) => f.toMap(),
    );
  }

  /// Método Único: Processa Alta, Calcula Valores e Salva tudo de uma vez
  Future<void> processarAltaEGerarFaturamento({
    required int idProntuario,
    required int? idInternacao,
    required int? idSala,
    required int? idLeito,
  }) async {
    try {
      print("Iniciando processamento de alta para Prontuário: $idProntuario");

      await db.transaction((txn) async {
        // 1. CÁLCULOS
        // Honorários
        final med = await txn.rawQuery('SELECT m.honorario FROM prontuario pr JOIN medico m ON pr.id_medico = m.id_medico WHERE pr.id_prontuario = ?', [idProntuario]);
        double valorHonorarios = (med.isNotEmpty) ? (med.first['honorario'] as num).toDouble() : 0.0;

        // Exames
        final ex = await txn.rawQuery('SELECT SUM(e.valor) as total FROM solicitacao_exame se JOIN exame e ON se.id_exame = e.id_exame WHERE se.id_prontuario = ?', [idProntuario]);
        double valorExames = (ex.first['total'] as num? ?? 0).toDouble();

        // Medicamentos/Consumo
        double valorConsumo = 0;
        if (idInternacao != null) {
          final cons = await txn.rawQuery('SELECT SUM(ci.quantidade * a.valor_unitario) as total FROM consumo_item ci JOIN almoxarifado a ON ci.id_almoxarifado = a.id_almoxarifado WHERE ci.id_internacao = ?', [idInternacao]);
          valorConsumo = (cons.first['total'] as num? ?? 0).toDouble();
        }

        double totalBruto = valorHonorarios + valorExames + valorConsumo;
        print("Cálculos: Honorários: $valorHonorarios, Exames: $valorExames, Consumo: $valorConsumo, Total: $totalBruto");

        // 2. INSERT NO FATURAMENTO
        int idFaturamento = await txn.insert('faturamento', {
          'id_prontuario': idProntuario,
          'id_internacao': idInternacao,
          'valor_medicamentos': valorConsumo,
          'valor_exames': valorExames,
          'valor_honorarios': valorHonorarios,
          'valor_consumo': valorConsumo,
          'valor_total': totalBruto,
          'status_pagamento': 'PENDENTE',
          'data_fechamento': DateTime.now().toIso8601String()
        });
        print("Faturamento inserido com ID: $idFaturamento");

        // 3. ARQUIVAR PRONTUÁRIO
        await txn.update('prontuario', {'status_prontuario': 'ARQUIVADO'}, where: 'id_prontuario = ?', whereArgs: [idProntuario]);
        print("Prontuário $idProntuario arquivado.");

        // 4. LIBERAR RECURSO (SALA OU LEITO)
        if (idSala != null) {
          await txn.update('sala', {'status': 'LIVRE'}, where: 'id_sala = ?', whereArgs: [idSala]);
          print("Sala $idSala liberada.");
        }
        if (idLeito != null) {
          await txn.update('leito', {'situacao': 'HIGIENIZACAO'}, where: 'id_leito = ?', whereArgs: [idLeito]);
          await txn.update('internacao', {'status_internacao': 'ALTA'}, where: 'id_internacao = ?', whereArgs: [idInternacao]);
          print("Leito $idLeito liberado e Internação marcada como ALTA.");
        }
      });
      print("Transação de alta finalizada com sucesso.");
    } catch (e) {
      print("ERRO CRÍTICO NA TRANSAÇÃO DE ALTA: $e");
      rethrow; // Isso é importante para capturar na tela
    }
  }

  Future<List<Map<String, dynamic>>> listarFaturamentosComPaciente() async {
    return await db.rawQuery('''
      SELECT f.*, p.nome as nome_paciente, p.cpf
      FROM faturamento f
      LEFT JOIN prontuario pr ON f.id_prontuario = pr.id_prontuario
      LEFT JOIN paciente p ON pr.id_paciente = p.id_paciente
      ORDER BY f.data_fechamento DESC
    ''');
  }

  Future<void> marcarComoPago(int idFaturamento, int idProntuario) async {
    await db.transaction((txn) async {
      // 1. Atualiza status no faturamento
      await txn.update(
        'faturamento', 
        {'status_pagamento': 'PAGO'}, 
        where: 'id_faturamento = ?', 
        whereArgs: [idFaturamento]
      );
      
      // 2. Arquiva o prontuário
      await txn.update(
        'prontuario', 
        {'status_prontuario': 'ARQUIVADO'}, 
        where: 'id_prontuario = ?', 
        whereArgs: [idProntuario]
      );
    });
  }
}