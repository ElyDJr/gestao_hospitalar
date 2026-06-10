// lib/domain/entities/prontuario.dart
class Prontuario {
  final int? id;
  final int idPaciente;
  final int idTriagem;
  final int idMedico;
  final String riscoEvasao;
  final String isolamento; // Aqui reside a informação definitiva
  final String? evolucao;
  final DateTime dataAbertura;
  final String statusProntuario;

  Prontuario({
    this.id,
    required this.idPaciente,
    required this.idTriagem,
    required this.idMedico,
    required this.riscoEvasao,
    required this.isolamento,
    this.evolucao,
    required this.dataAbertura,
    required this.statusProntuario,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_prontuario': id,
      'id_paciente': idPaciente,
      'id_triagem': idTriagem,
      'id_medico': idMedico,
      'risco_evasao': riscoEvasao,
      'isolamento': isolamento,
      'evolucao': evolucao,
      'data_abertura': dataAbertura.toIso8601String(),
      'status_prontuario': statusProntuario,
    };
  }
}