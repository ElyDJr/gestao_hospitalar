import 'entitie.dart';

class LogProntuario extends Entitie {
  int idProntuario;
  String? responsavel;
  DateTime? dataAlteracao;
  String? descricao;

  LogProntuario({
    super.id, // Corresponde ao id_log
    required this.idProntuario,
    this.responsavel,
    this.dataAlteracao,
    this.descricao,
  });
}