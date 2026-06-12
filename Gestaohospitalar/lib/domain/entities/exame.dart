import 'entitie.dart';

class Exame extends Entitie {
  String nome;
  double? valor;
  String? descricao;

  Exame({
    super.id,
    required this.nome,
    this.valor,
    this.descricao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_exame': id,
      'nome': nome,
      'valor': valor,
      'descricao': descricao,
    };
  }

  factory Exame.fromMap(Map<String, dynamic> map) {
    return Exame(
      id: map['id_exame'] != null ? map['id_exame'] as int : (map['id'] as int?),
      nome: map['nome'] as String? ?? 'Sem Nome',
      valor: map['valor'] != null ? (map['valor'] as num).toDouble() : null,
      descricao: map['descricao'] as String?,
    );
  }
}