// lib/domain/entities/paciente_convenio.dart
import 'entitie.dart';

class PacienteConvenio extends Entitie {
  final int idPaciente;
  final int idConvenio;
  final String? numeroCarteira;
  final DateTime validade; // SQLite salva como TEXT (ISO8601)
  final bool ativo;

  PacienteConvenio({
    super.id,
    required this.idPaciente,
    required this.idConvenio,
    this.numeroCarteira,
    required this.validade,
    this.ativo = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_paciente_convenio': id,
      'id_paciente': idPaciente,
      'id_convenio': idConvenio,
      'numero_carteira': numeroCarteira,
      'validade': "${validade.year}-${validade.month.toString().padLeft(2, '0')}-${validade.day.toString().padLeft(2, '0')}",
      'ativo': ativo ? 1 : 0,
    };
  }

  factory PacienteConvenio.fromMap(Map<String, dynamic> map) {
    return PacienteConvenio(
      id: map['id_paciente_convenio'],
      idPaciente: map['id_paciente'],
      idConvenio: map['id_convenio'],
      numeroCarteira: map['numero_carteira'],
      validade: DateTime.parse(map['validade']),
      ativo: map['ativo'] == 1,
    );
  }
}