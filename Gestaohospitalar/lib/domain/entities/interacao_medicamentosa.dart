import 'entitie.dart';

class InteracaoMedicamentosa extends Entitie {
  int idMedicamento1;
  int idMedicamento2;
  String? gravidade;
  String? descricao;

  InteracaoMedicamentosa({
    super.id, // Corresponde ao id_interacao
    required this.idMedicamento1,
    required this.idMedicamento2,
    this.gravidade,
    this.descricao,
  });
}