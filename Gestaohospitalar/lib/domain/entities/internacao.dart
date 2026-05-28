import 'entitie.dart';

class Internacao extends Entitie {
  int idProntuario;
  int idLeito;
  DateTime? dataEntrada;
  DateTime? dataAlta;
  String? isolamento;
  String? statusInternacao;

  Internacao({
    super.id, // Corresponde ao id_internacao
    required this.idProntuario,
    required this.idLeito,
    this.dataEntrada,
    this.dataAlta,
    this.isolamento,
    this.statusInternacao,
  });
}