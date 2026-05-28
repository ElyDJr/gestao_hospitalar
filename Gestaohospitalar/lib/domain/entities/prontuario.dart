import 'entitie.dart';

class Prontuario extends Entitie {
  int idPaciente;
  int idTriagem;
  int idMedico;
  String riscoEvasao;
  String isolamento;
  String? evolucao;
  DateTime? dataAbertura;
  String? statusProntuario;

  Prontuario({
    super.id, // Corresponde ao id_prontuario
    required this.idPaciente,
    required this.idTriagem,
    required this.idMedico,
    required this.riscoEvasao,
    required this.isolamento,
    this.evolucao,
    this.dataAbertura,
    this.statusProntuario,
  });
}