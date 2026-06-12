import 'entitie.dart';

class SolicitacaoExame extends Entitie {
  int idProntuario;
  int idExame;
  int idMedico;
  DateTime? dataSolicitacao;
  String? statusExame;
  String? resultado;

  SolicitacaoExame({
    super.id, // Corresponde ao id_solicitacao
    required this.idProntuario,
    required this.idExame,
    required this.idMedico,
    this.dataSolicitacao,
    this.statusExame,
    this.resultado,
  });

  // 👇 Mapeia para o banco de dados
  Map<String, dynamic> toMap() {
    return {
      'id_solicitacao': id,
      'id_prontuario': idProntuario,
      'id_exame': idExame,
      'id_medico': idMedico,
      'data_solicitacao': dataSolicitacao?.toIso8601String(),
      'status_exame': statusExame,
      'resultado': resultado,
    };
  }

  // 👇 Lê do banco de dados
  factory SolicitacaoExame.fromMap(Map<String, dynamic> map) {
    return SolicitacaoExame(
      id: map['id_solicitacao'] != null ? map['id_solicitacao'] as int : (map['id'] as int?),
      idProntuario: map['id_prontuario'] as int,
      idExame: map['id_exame'] as int,
      idMedico: map['id_medico'] as int,
      dataSolicitacao: map['data_solicitacao'] != null ? DateTime.tryParse(map['data_solicitacao']) : null,
      statusExame: map['status_exame'] as String?,
      resultado: map['resultado'] as String?,
    );
  }
}