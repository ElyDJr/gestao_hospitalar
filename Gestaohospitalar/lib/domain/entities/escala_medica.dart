class EscalaMedica {
  final int? id;
  final int idMedico;
  final String? nomeMedico; // Usado para exibição na tela
  final String dataEscala;
  final String horaInicio;
  final String horaFim;
  final bool isPlantao;

  EscalaMedica({
    this.id,
    required this.idMedico,
    this.nomeMedico,
    required this.dataEscala,
    required this.horaInicio,
    required this.horaFim,
    this.isPlantao = false,
  });

  factory EscalaMedica.fromMap(Map<String, dynamic> map) {
    return EscalaMedica(
      id: map['id_escala'],
      idMedico: map['id_medico'],
      nomeMedico: map['nome_medico'], // Vem do JOIN com a tabela medico
      dataEscala: map['data_escala'],
      horaInicio: map['hora_inicio'],
      horaFim: map['hora_fim'],
      isPlantao: map['is_plantao'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_escala': id,
      'id_medico': idMedico,
      'data_escala': dataEscala,
      'hora_inicio': horaInicio,
      'hora_fim': horaFim,
      'is_plantao': isPlantao ? 1 : 0,
    };
  }
}