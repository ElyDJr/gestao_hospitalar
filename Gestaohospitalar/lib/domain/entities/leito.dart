class Leito {
  final int? id;
  final String? numero;
  final int? idAla; 
  final DateTime? dataHigienizacao;
  final String? situacao;
  final String? tipo; // 🟢 Adicionado aqui

  Leito({
    this.id,
    this.numero,
    this.idAla, 
    this.dataHigienizacao,
    this.situacao,
    this.tipo, // 🟢 Adicionado aqui no construtor
  });

  Map<String, dynamic> toMap() {
    return {
      'id_leito': id,
      'numero': numero,
      'id_ala': idAla, 
      'data_higienizacao': dataHigienizacao?.toIso8601String(),
      'situacao': situacao,
      'tipo': tipo, // 🟢 Adicionado para salvar no banco/mapa
    };
  }

  factory Leito.fromMap(Map<String, dynamic> map) {
    return Leito(
      id: map['id_leito'],
      numero: map['numero'],
      idAla: map['id_ala'] != null ? int.tryParse(map['id_ala'].toString()) : null, 
      dataHigienizacao: map['data_higienizacao'] != null
          ? DateTime.parse(map['data_higienizacao'])
          : null,
      situacao: map['situacao'],
      tipo: map['tipo'], // 🟢 Adicionado para ler do banco/mapa
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Leito && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}