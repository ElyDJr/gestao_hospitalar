// lib/domain/entities/triagem.dart
import 'entitie.dart';

class Triagem extends Entitie {
  final int idPaciente;
  final String? responsavelTriagem;
  final String? pressao;
  final double? temperatura;
  final int? frequenciaCardiaca;
  final int? saturacao;
  final int? escalaDor;
  final String? risco;
  final String? queixa;
  final String? alergias;
  final String? observacoes;
  final String? internacao;

  Triagem({
    super.id,
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
    this.internacao,
  });

  // ✅ ADICIONE ESTE MÉTODO:
  Triagem copyWith({
    String? observacoes,
    String? internacao,
  }) {
    return Triagem(
      id: id,
      idPaciente: idPaciente,
      responsavelTriagem: responsavelTriagem,
      pressao: pressao,
      temperatura: temperatura,
      frequenciaCardiaca: frequenciaCardiaca,
      saturacao: saturacao,
      escalaDor: escalaDor,
      risco: risco,
      queixa: queixa,
      alergias: alergias,
      observacoes: observacoes ?? this.observacoes, // Usa o novo valor ou mantém o antigo
      internacao: internacao ?? this.internacao,     // Usa o novo valor ou mantém o antigo
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_triagem': id,
      'id_paciente': idPaciente,
      'responsavel_triagem': responsavelTriagem,
      'pressao': pressao,
      'temperatura': temperatura,
      'frequencia_cardiaca': frequenciaCardiaca,
      'saturacao': saturacao,
      'escala_dor': escalaDor,
      'risco': risco,
      'queixa': queixa,
      'alergias': alergias,
      'observacoes': observacoes,
      'internacao': internacao,
    };
  }

  factory Triagem.fromMap(Map<String, dynamic> map) {
    return Triagem(
      id: map['id_triagem'],
      idPaciente: map['id_paciente'],
      responsavelTriagem: map['responsavel_triagem'],
      pressao: map['pressao'],
      temperatura: map['temperatura'] != null ? (map['temperatura'] as num).toDouble() : null,
      frequenciaCardiaca: map['frequencia_cardiaca'],
      saturacao: map['saturacao'],
      escalaDor: map['escala_dor'],
      risco: map['risco'],
      queixa: map['queixa'],
      alergias: map['alergias'],
      observacoes: map['observacoes'],
      internacao: map['internacao'],
    );
  }
}