import 'entitie.dart';

class PacienteConvenio extends Entitie {
  int idPaciente;
  int idConvenio;
  String? numeroCarteira;
  DateTime validade;
  bool ativo;

  PacienteConvenio({
    super.id, // Corresponde ao id_paciente_convenio
    required this.idPaciente,
    required this.idConvenio,
    this.numeroCarteira,
    required this.validade,
    this.ativo = true,
  });
}