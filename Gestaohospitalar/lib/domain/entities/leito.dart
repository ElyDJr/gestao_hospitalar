class Leito {
  final int? id;
  final String? numero;
  final String? ala; // Substitui o 'tipo'
  final DateTime? dataHigienizacao;
  final String? situacao; // Substitui o 'status' (VAGO, OCUPADO, HIGIENIZACAO)

  Leito({
    this.id,
    this.numero,
    this.ala,
    this.dataHigienizacao,
    this.situacao,
  });

  // Converte a classe para o formato que o SQLite entende (snake_case)
  Map<String, dynamic> toMap() {
    return {
      'id_leito': id,
      'numero': numero,
      'ala': ala,
      'data_higienizacao': dataHigienizacao?.toIso8601String(),
      'situacao': situacao,
    };
  }

  // Converte o retorno do SQLite para a classe Dart
  factory Leito.fromMap(Map<String, dynamic> map) {
    return Leito(
      id: map['id_leito'],
      numero: map['numero'],
      ala: map['ala'],
      dataHigienizacao: map['data_higienizacao'] != null 
          ? DateTime.parse(map['data_higienizacao']) 
          : null,
      situacao: map['situacao'],
    );
  }
}