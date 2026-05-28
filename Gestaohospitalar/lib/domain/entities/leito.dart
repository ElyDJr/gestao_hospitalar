import 'entitie.dart';

class Leito extends Entitie {
  String? numero;
  String? ala;
  DateTime? dataHigienizacao;
  String? situacao;

  Leito({
    super.id, // Corresponde ao id_leito
    this.numero,
    this.ala,
    this.dataHigienizacao,
    this.situacao,
  });
}