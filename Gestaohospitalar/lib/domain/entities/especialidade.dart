// lib/domain/entities/especialidade.dart
import 'entitie.dart';

class Especialidade extends Entitie {
  final String? descricaoEspecialidade; // Mudei para bater com o banco

  Especialidade({
    super.id,
    this.descricaoEspecialidade,
  });

  // Converte de Dart para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id_especialidade': id,
      'descricao_especialidade': descricaoEspecialidade, // Coluna exata do seu SQLite!
    };
  }

  // Converte de SQLite para Dart
  factory Especialidade.fromMap(Map<String, dynamic> map) {
    return Especialidade(
      id: map['id_especialidade'],
      descricaoEspecialidade: map['descricao_especialidade'],
    );
  }
}