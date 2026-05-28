import 'entitie.dart';

class Medicamento extends Entitie {
  int idAlmoxarifado;
  String? principioAtivo;
  String? contraindicacoes;

  Medicamento({
    super.id, // Corresponde ao id_medicamento
    required this.idAlmoxarifado,
    this.principioAtivo,
    this.contraindicacoes,
  });
}