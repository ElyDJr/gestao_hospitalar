class Internacao {
  final int? id;
  final int idProntuario;
  final int idLeito;
  final DateTime? dataEntrada; // O erro pedia um DateTime aqui
  final DateTime? dataAlta;
  final String? isolamento; // No SQL é 'SIM' ou 'NAO'
  final String? statusInternacao;

  Internacao({
    this.id,
    required this.idProntuario,
    required this.idLeito,
    this.dataEntrada,
    this.dataAlta,
    this.isolamento,
    this.statusInternacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_internacao': id,
      'id_prontuario': idProntuario,
      'id_leito': idLeito,
      'data_entrada': dataEntrada?.toIso8601String(),
      'data_alta': dataAlta?.toIso8601String(),
      'isolamento': isolamento,
      'status_internacao': statusInternacao,
    };
  }

  factory Internacao.fromMap(Map<String, dynamic> map) {
    return Internacao(
      id: map['id_internacao'],
      idProntuario: map['id_prontuario'],
      idLeito: map['id_leito'],
      dataEntrada: map['data_entrada'] != null 
          ? DateTime.parse(map['data_entrada']) 
          : null,
      dataAlta: map['data_alta'] != null 
          ? DateTime.parse(map['data_alta']) 
          : null,
      isolamento: map['isolamento'],
      statusInternacao: map['status_internacao'],
    );
  }
}