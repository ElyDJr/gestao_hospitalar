import 'entitie.dart';

class Auditoria extends Entitie {
  int? idFaturamento;
  String? auditor;
  DateTime? dataAuditoria;
  String? statusAuditoria;
  String? observacoes;
  bool? conformidade;

  Auditoria({
    super.id, // Corresponde ao id_auditoria
    this.idFaturamento,
    this.auditor,
    this.dataAuditoria,
    this.statusAuditoria,
    this.observacoes,
    this.conformidade,
  });
}