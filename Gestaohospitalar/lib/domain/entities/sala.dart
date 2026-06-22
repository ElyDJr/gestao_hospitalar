import 'entitie.dart';

class Sala extends Entitie {
  String? nomeSala;
  String status;

  Sala({
    super.id,
    this.nomeSala,
    this.status = 'LIVRE', // Valor padrão
  });

  /// Converte o objeto para um Map para salvar no banco
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id_sala': id,
      'nome_sala': nomeSala,
      'status': status,
    };
  }

  /// Cria o objeto a partir de um Map do banco
  factory Sala.fromMap(Map<String, dynamic> map) {
    return Sala(
      id: map['id_sala'],
      nomeSala: map['nome_sala'],
      status: map['status'] ?? 'LIVRE',
    );
  }
}