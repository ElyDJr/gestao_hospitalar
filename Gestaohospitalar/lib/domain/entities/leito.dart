class Leito {
  final int? id;
  final String? numero;
  final String? ala;
  final DateTime? dataHigienizacao;
  final String? situacao;

  Leito({
    this.id,
    this.numero,
    this.ala,
    this.dataHigienizacao,
    this.situacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_leito': id,
      'numero': numero,
      'ala': ala,
      'data_higienizacao': dataHigienizacao?.toIso8601String(),
      'situacao': situacao,
    };
  }

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

  // 🟢 ADICIONE ESTAS LINHAS AQUI (Sobrescrita de Igualdade)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Leito && other.id == id; // Dois leitos são o mesmo se o ID for igual
  }

  @override
  int get hashCode => id.hashCode;
}