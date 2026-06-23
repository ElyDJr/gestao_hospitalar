// import 'package:flutter/material.dart';
// import 'package:sqflite/sqflite.dart';
// import '../entities/faturamento.dart';
// import '../repository/entitie_repository.dart';
// import '../../data/repositories/generic_repository_impl.dart';
// import '../../data/resources/database_provider.dart';

// class FaturamentoService extends ChangeNotifier {
//   late final EntitieRepository<Faturamento> _repository;
//   final Database db;

//   FaturamentoService(this.db) {
//     _repository = GenericRepositoryImpl<Faturamento>(
//       db: db,
//       tableName: 'faturamento',
//       fromMap: (map) => Faturamento.fromMap(map),
//       toMap: (f) => f.toMap(),
//     );
//   }

//   Future<List<Faturamento>> listarFaturamentos() async {
//     return await _repository.findAll();
//   }

//   Future<void> salvarFaturamento(Faturamento f) async {
//     if (f.id == null) {
//       await _repository.create(f);
//     } else {
//       await _repository.update(f);
//     }
//     notifyListeners();
//   }

//   // Adicione este método para buscar com o JOIN do nome do paciente
//   Future<List<Map<String, dynamic>>> listarFaturamentosComPaciente() async {
//     final db = await DatabaseProvider.instance.database;
//     return await db.rawQuery('''
//     SELECT f.*, p.nome as nome_paciente
//     FROM faturamento f
//     JOIN paciente p ON f.id_paciente = p.id_paciente
//     ORDER BY f.data_fechamento DESC
//   ''');
//   }

//   Future<void> gerarContaFinal(int idProntuario, bool isLeito) async {
//   final db = await DatabaseProvider.instance.database;
  
//   // 1. Soma Medicamentos (Exemplo de query)
//     final meds = await db.rawQuery('SELECT SUM(total) as val FROM consumo_item WHERE id_prontuario = ?', [idProntuario]);
//     double valMeds = (meds.first['val'] as num? ?? 0).toDouble();

//     // 2. Soma Exames
//     final exames = await db.rawQuery('SELECT SUM(valor) as val FROM solicitacao_exame WHERE id_prontuario = ?', [idProntuario]);
//     double valExames = (exames.first['val'] as num? ?? 0).toDouble();

//     // 3. Soma Honorários (Exemplo fixo ou baseado em carga horária/medico)
//     double valHonorarios = 300.0;

//     // 4. Salva no Faturamento
//     await db.insert('faturamento', {
//       'id_prontuario': idProntuario,
//       'valor_medicamentos': valMeds,
//       'valor_exames': valExames,
//       'valor_honorarios': valHonorarios,
//       'valor_total': (valMeds + valExames + valHonorarios),
//       'status_pagamento': 'PENDENTE'
//     });
//   }

// }

import 'package:sqflite/sqflite.dart';


class FaturamentoService {
  final Database db;
  FaturamentoService(this.db);

  // Calcula tudo dinamicamente e retorna um resumo para o PDF/UI
  Future<Map<String, dynamic>> calcularConta(int idProntuario, int idInternacao) async {
    // 1. Honorários Médicos
    final med = await db.rawQuery('''
      SELECT m.honorario FROM prontuario pr
      JOIN medico m ON pr.id_medico = m.id_medico
      WHERE pr.id_prontuario = ?''', [idProntuario]);
    double valorHonorarios = (med.isNotEmpty) ? (med.first['honorario'] as num).toDouble() : 0.0;

    // 2. Exames
    final ex = await db.rawQuery('''
      SELECT SUM(e.valor) as total FROM solicitacao_exame se
      JOIN exame e ON se.id_exame = e.id_exame
      WHERE se.id_prontuario = ?''', [idProntuario]);
    double valorExames = (ex.first['total'] as num? ?? 0).toDouble();

    // 3. Medicamentos/Consumo (da tabela consumo_item)
    double valorConsumo = 0;
    if (idInternacao != null) {
      final cons = await db.rawQuery('''
        SELECT SUM(ci.quantidade * a.valor_unitario) as total
        FROM consumo_item ci
        JOIN almoxarifado a ON ci.id_almoxarifado = a.id_almoxarifado
        WHERE ci.id_internacao = ?''', [idInternacao]);
      valorConsumo = (cons.first['total'] as num? ?? 0).toDouble();
    }

    // 4. Busca o desconto do convênio do paciente
    final conv = await db.rawQuery('''
      SELECT c.percentual_cobertura FROM paciente_convenio pc
      JOIN convenio c ON pc.id_convenio = c.id_convenio
      JOIN prontuario pr ON pr.id_paciente = pc.id_paciente
      WHERE pr.id_prontuario = ? AND pc.ativo = 1''', [idProntuario]);
    
    double percentualCobertura = (conv.isNotEmpty) ? (conv.first['percentual_cobertura'] as num).toDouble() : 0.0;
    
    double totalBruto = valorHonorarios + valorExames + valorConsumo;
    double valorAbatido = totalBruto * (percentualCobertura / 100);
    double totalAPagar = totalBruto - valorAbatido;

    return {
      'honorarios': valorHonorarios,
      'exames': valorExames,
      'consumo': valorConsumo,
      'total_bruto': totalBruto,
      'desconto_plano': valorAbatido,
      'total_a_pagar': totalAPagar,
      'percentual': percentualCobertura
    };
  }
}