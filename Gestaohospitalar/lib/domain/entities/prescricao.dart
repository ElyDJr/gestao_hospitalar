import 'entitie.dart';

class Prescricao extends Entitie {
  int idProntuario;
  int idMedico;
  int idMedicamento;
  String? dosagem;
  String? aplicacao;
  DateTime horario;
  String? observacao;

  Prescricao({
    super.id, // Corresponde ao id_prescricao
    required this.idProntuario,
    required this.idMedico,
    required this.idMedicamento,
    this.dosagem,
    this.aplicacao,
    required this.horario,
    this.observacao,
  });
}