import 'entitie.dart';

class ConsumoItem extends Entitie {
  int idInternacao;
  int idAlmoxarifado;
  int quantidade;
  DateTime? dataConsumo;
  String? observacao;

  ConsumoItem({
    super.id, // Corresponde ao id_consumo
    required this.idInternacao,
    required this.idAlmoxarifado,
    required this.quantidade,
    this.dataConsumo,
    this.observacao,
  });
}