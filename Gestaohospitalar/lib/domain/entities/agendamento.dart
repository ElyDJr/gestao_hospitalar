import 'entitie.dart';

class Agendamento extends Entitie {
  int? idPaciente;
  int? idMedico;
  int? idSala;
  DateTime? dataHora;
  String? status;

  Agendamento({
    super.id, // Corresponde ao id_agendamento
    this.idPaciente,
    this.idMedico,
    this.idSala,
    this.dataHora,
    this.status,
  });
}