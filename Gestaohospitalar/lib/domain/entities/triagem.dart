import 'entitie.dart';

class Triagem extends Entitie {
  int idPaciente;
  String? responsavelTriagem;
  String? pressao;
  double? temperatura;
  int? frequenciaCardiaca;
  int? saturacao;
  int? escalaDor;
  String? risco;
  String? queixa;
  String? alergias;
  String? observacoes;
  String? internaca; // Alinhado com o campo 'internaca TEXT' do seu SQL

  Triagem({
    super.id, // Corresponde ao id_triagem
    required this.idPaciente,
    this.responsavelTriagem,
    this.pressao,
    this.temperatura,
    this.frequenciaCardiaca,
    this.saturacao,
    this.escalaDor,
    this.risco,
    this.queixa,
    this.alergias,
    this.observacoes,
    this.internaca,
  });
}