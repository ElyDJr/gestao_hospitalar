import 'entitie.dart';

class LogProntuario extends Entitie {
  final int? idLog;
  final int idProntuario;
  final String responsavel;
  final DateTime dataAlteracao;
  final String descricao;

  LogProntuario({
    this.idLog,
    required this.idProntuario,
    required this.responsavel,
    required this.dataAlteracao,
    required this.descricao,
  });

  factory LogProntuario.fromMap(Map<String, dynamic> map) {
    return LogProntuario(
      idLog: map['id_log'],
      idProntuario: map['id_prontuario'],
      responsavel: map['responsavel'],
      dataAlteracao: DateTime.parse(map['data_alteracao']),
      descricao: map['descricao'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id_log': idLog,
      'id_prontuario': idProntuario,
      'responsavel': responsavel,
      'data_alteracao': dataAlteracao.toIso8601String(),
      'descricao': descricao,
    };
  }
}