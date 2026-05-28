import 'entitie.dart';

class Especialidade extends Entitie {
  String descricaoEspecialidade;

  Especialidade({
    super.id, // Corresponde ao id_especialidade
    required this.descricaoEspecialidade,
  });
}