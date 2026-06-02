// lib/domain/entities/medico.dart
import 'entitie.dart';

class Medico extends Entitie {
  final int? idEspecialidade;
  final String? nome;
  final String? telefone;
  final String? email;
  final String? crm;
  final double? honorario;

  Medico({
    super.id,
    this.idEspecialidade,
    this.nome,
    this.telefone,
    this.email,
    this.crm,
    this.honorario,
  });

  // Converte de Dart para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id_medico': id,
      'id_especialidade': idEspecialidade,
      'nome': nome,
      'telefone': telefone,
      'email': email,
      'crm': crm,
      'honorario': honorario,
    };
  }

  // Converte de SQLite para Dart
  factory Medico.fromMap(Map<String, dynamic> map) {
    return Medico(
      id: map['id_medico'],
      idEspecialidade: map['id_especialidade'],
      nome: map['nome'],
      telefone: map['telefone'],
      email: map['email'],
      crm: map['crm'],
      honorario: map['honorario'] != null ? (map['honorario'] as num).toDouble() : null,
    );
  }
}