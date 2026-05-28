import 'entitie.dart';

class Faturamento extends Entitie {
  int idInternacao;
  double valorMedicamentos;
  double valorExames;
  double valorInternacao;
  double valorHonorarios;
  double valorConsumo;
  double? valorTotal;
  String? statusPagamento;
  DateTime? dataFechamento;
  String? observacao;

  Faturamento({
    super.id, // Corresponde ao id_faturamento
    required this.idInternacao,
    this.valorMedicamentos = 0,
    this.valorExames = 0,
    this.valorInternacao = 0,
    this.valorHonorarios = 0,
    this.valorConsumo = 0,
    this.valorTotal,
    this.statusPagamento,
    this.dataFechamento,
    this.observacao,
  });
}