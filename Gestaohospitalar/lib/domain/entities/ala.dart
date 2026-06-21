import 'entitie.dart';

class Ala extends Entitie{
  @override
  final int? id;
  final String nomeAla;
  final String andar;

  Ala({
    this.id,
    required this.nomeAla,
    required this.andar,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_ala': id,
      'nome_ala': nomeAla,
      'andar': andar,
    };
  }

  factory Ala.fromMap(Map<String, dynamic> map) {
    return Ala(
      // Procura pelo ID tanto na chave da tabela 'id_ala' quanto na genérica 'id'
      id: map['id_ala'] != null
          ? int.tryParse(map['id_ala'].toString())
          : (map['id'] != null ? int.tryParse(map['id'].toString()) : null),
      nomeAla: map['nome']?.toString() ?? map['nome_ala']?.toString() ?? 'Sem Nome',
      andar: map['andar']?.toString() ?? 'Sem Andar',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Ala && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}