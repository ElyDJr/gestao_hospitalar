import 'entitie.dart';

class Sala extends Entitie {
  String? nome;
  String? tipo;
  String? status;

  Sala({
    super.id, // Corresponde ao id_sala
    this.nome,
    this.tipo,
    this.status,
  });
}