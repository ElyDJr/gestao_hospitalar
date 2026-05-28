import 'entitie.dart';

class Exame extends Entitie {
  String nome;
  double? valor;
  String? descricao;

  Exame({
    super.id, // Corresponde ao id_exame
    required this.nome,
    this.valor,
    this.descricao,
  });
}