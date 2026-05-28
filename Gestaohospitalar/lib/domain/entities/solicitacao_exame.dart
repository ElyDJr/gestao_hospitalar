import 'entitie.dart';

class SolicitacaoExame extends Entitie {
  int idProntuario;
  int idExame;
  int idMedico;
  DateTime? dataSolicitacao;
  String? statusExame;
  String? resultado;

  SolicitacaoExame({
    super.id, // Corresponde ao id_solicitacao
    required this.idProntuario,
    required this.idExame,
    required this.idMedico,
    this.dataSolicitacao,
    this.statusExame,
    this.resultado,
  });
}