import 'entitie.dart';

class Auditoria extends Entitie {
  final int? idAuditoria;
  final int idFaturamento;
  final String auditor;
  final DateTime dataAuditoria;
  final String statusAuditoria;
  final String observacoes;
  final bool conformidade;

  Auditoria({
    this.idAuditoria,
    required this.idFaturamento,
    required this.auditor,
    required this.dataAuditoria,
    this.statusAuditoria = 'PENDENTE',
    this.observacoes = '',
    required this.conformidade,
  });

  factory Auditoria.fromMap(Map<String, dynamic> map) {
    return Auditoria(
      idAuditoria: map['id_auditoria'],
      idFaturamento: map['id_faturamento'],
      auditor: map['auditor'],
      dataAuditoria: DateTime.parse(map['data_auditoria']),
      statusAuditoria: map['status_auditoria'],
      observacoes: map['observacoes'],
      conformidade: map['conformidade'] == 1,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id_auditoria': idAuditoria,
      'id_faturamento': idFaturamento,
      'auditor': auditor,
      'data_auditoria': dataAuditoria.toIso8601String(),
      'status_auditoria': statusAuditoria,
      'observacoes': observacoes,
      'conformidade': conformidade ? 1 : 0,
    };
  }
}