import 'entitie.dart';

class Almoxarifado extends Entitie {
  String nome;
  String? categoria;
  String? descricao;
  int quantidade;
  String? unidade;
  double valorUnitario;
  int estoqueMinimo;
  String? lote;
  DateTime? validade;

  Almoxarifado({
    super.id, // Corresponde ao id_almoxarifado
    required this.nome,
    this.categoria,
    this.descricao,
    this.quantidade = 0,
    this.unidade,
    required this.valorUnitario,
    this.estoqueMinimo = 0,
    this.lote,
    this.validade,
  });
}