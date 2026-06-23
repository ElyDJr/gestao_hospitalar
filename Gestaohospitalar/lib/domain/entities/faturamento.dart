import 'entitie.dart';

class Faturamento extends Entitie {
  final int idProntuario;
  final int? idInternacao;
  final double valorMedicamentos;
  final double valorExames;
  final double valorInternacao;
  final double valorHonorarios;
  final double valorConsumo;
  final double? valorTotal;
  final String statusPagamento;
  final DateTime? dataFechamento;
  final String? observacao;

  Faturamento({
    super.id, // id_faturamento
    required this.idProntuario,
    this.idInternacao,
    this.valorMedicamentos = 0.0,
    this.valorExames = 0.0,
    this.valorInternacao = 0.0,
    this.valorHonorarios = 0.0,
    this.valorConsumo = 0.0,
    this.valorTotal,
    this.statusPagamento = 'PENDENTE',
    this.dataFechamento,
    this.observacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_faturamento': id,
      'id_prontuario': idProntuario,
      'id_internacao': idInternacao,
      'valor_medicamentos': valorMedicamentos,
      'valor_exames': valorExames,
      'valor_internacao': valorInternacao,
      'valor_honorarios': valorHonorarios,
      'valor_consumo': valorConsumo,
      'valor_total': valorTotal,
      'status_pagamento': statusPagamento,
      'data_fechamento': dataFechamento?.toIso8601String(),
      'observacao': observacao,
    };
  }

  factory Faturamento.fromMap(Map<String, dynamic> map) {
    return Faturamento(
      id: map['id_faturamento'],
      idProntuario: map['id_prontuario'],
      idInternacao: map['id_internacao'],
      valorMedicamentos: (map['valor_medicamentos'] as num).toDouble(),
      valorExames: (map['valor_exames'] as num).toDouble(),
      valorInternacao: (map['valor_internacao'] as num).toDouble(),
      valorHonorarios: (map['valor_honorarios'] as num).toDouble(),
      valorConsumo: (map['valor_consumo'] as num).toDouble(),
      valorTotal: (map['valor_total'] as num?)?.toDouble(),
      statusPagamento: map['status_pagamento'],
      dataFechamento: map['data_fechamento'] != null ? DateTime.parse(map['data_fechamento']) : null,
      observacao: map['observacao'],
    );
  }
}