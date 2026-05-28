import 'entitie.dart';

class Medico extends Entitie {
  int idEspecialidade;
  String nome;
  String? telefone;
  String? email;
  String crm;
  double? honorario;

  Medico({
    super.id, // Corresponde ao id_medico
    required this.idEspecialidade,
    required this.nome,
    this.telefone,
    this.email,
    required this.crm,
    this.honorario,
  });
}