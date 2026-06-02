// lib/domain/entities/medico.dart
import 'entitie.dart';

class Medico extends Entitie {
  final int? ativo; // ✅ Soft Delete
  final int? idEspecialidade;
  final String? nome;
  final String? telefone;
  final String? email;
  final String? crm;
  final double? honorario;

  Medico({
    super.id,
    this.ativo = 1,
    this.idEspecialidade,
    this.nome,
    this.telefone,
    this.email,
    this.crm,
    this.honorario,
  });

  Medico copyWith({int? ativo}) {
    return Medico(
      id: id,
      ativo: ativo ?? this.ativo,
      idEspecialidade: idEspecialidade,
      nome: nome,
      telefone: telefone,
      email: email,
      crm: crm,
      honorario: honorario,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_medico': id,
      'ativo': ativo ?? 1,
      'id_especialidade': idEspecialidade,
      'nome': nome,
      'telefone': telefone,
      'email': email,
      'crm': crm,
      'honorario': honorario,
    };
  }

  factory Medico.fromMap(Map<String, dynamic> map) {
    return Medico(
      id: map['id_medico'],
      ativo: map['ativo'],
      idEspecialidade: map['id_especialidade'],
      nome: map['nome'],
      telefone: map['telefone'],
      email: map['email'],
      crm: map['crm'],
      honorario: map['honorario'] != null ? (map['honorario'] as num).toDouble() : null,
    );
  }
}