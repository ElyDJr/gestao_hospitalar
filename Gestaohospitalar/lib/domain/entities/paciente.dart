// lib/domain/entities/paciente.dart
import 'entitie.dart';

class Paciente extends Entitie {
  final int? ativo; // 1 para Ativo, 0 para Arquivado
  final String? nome;
  final String? cpf;
  final String? sexo;
  final DateTime? nascimento;
  final String? alergias;
  final String? tipoSanguineo;
  final String? historicoClinico;
  final String? telefone;
  final String? rua;
  final int? numeroCasa;
  final String? bairro;
  final String? cidade;
  final String? estado;
  final String? cep;
  final String? nomeResponsavel;

  Paciente({
    super.id,
    this.ativo = 1, // Por padrão, todo paciente nasce ativo
    this.nome,
    this.cpf,
    this.sexo,
    this.nascimento,
    this.alergias,
    this.tipoSanguineo,
    this.historicoClinico,
    this.telefone,
    this.rua,
    this.numeroCasa,
    this.bairro,
    this.cidade,
    this.estado,
    this.cep,
    this.nomeResponsavel,
  });

  // ✅ Método mágico agora aceita atualizar QUALQUER atributo
  Paciente copyWith({
    int? id,
    int? ativo,
    String? nome,
    String? cpf,
    String? sexo,
    DateTime? nascimento,
    String? alergias,
    String? tipoSanguineo,
    String? historicoClinico,
    String? telefone,
    String? rua,
    int? numeroCasa,
    String? bairro,
    String? cidade,
    String? estado,
    String? cep,
    String? nomeResponsavel,
  }) {
    return Paciente(
      id: id ?? this.id,
      ativo: ativo ?? this.ativo,
      nome: nome ?? this.nome,
      cpf: cpf ?? this.cpf,
      sexo: sexo ?? this.sexo,
      nascimento: nascimento ?? this.nascimento,
      alergias: alergias ?? this.alergias,
      tipoSanguineo: tipoSanguineo ?? this.tipoSanguineo,
      historicoClinico: historicoClinico ?? this.historicoClinico, // ✅ Agora ele recebe o valor novo da Triagem!
      telefone: telefone ?? this.telefone,
      rua: rua ?? this.rua,
      numeroCasa: numeroCasa ?? this.numeroCasa,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
      estado: estado ?? this.estado,
      cep: cep ?? this.cep,
      nomeResponsavel: nomeResponsavel ?? this.nomeResponsavel,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_paciente': id,
      'ativo': ativo ?? 1, // Salva no banco
      'nome': nome,
      'cpf': cpf,
      'sexo': sexo,
      'nascimento': nascimento != null ? "${nascimento!.year}-${nascimento!.month.toString().padLeft(2, '0')}-${nascimento!.day.toString().padLeft(2, '0')}" : null,
      'alergias': alergias,
      'tipo_sanguineo': tipoSanguineo,
      'historico_clinico': historicoClinico,
      'telefone': telefone,
      'rua': rua,
      'numero_casa': numeroCasa,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'cep': cep,
      'nome_responsavel': nomeResponsavel,
    };
  }

  factory Paciente.fromMap(Map<String, dynamic> map) {
    return Paciente(
      id: map['id_paciente'],
      ativo: map['ativo'], // Lê do banco
      nome: map['nome'],
      cpf: map['cpf'],
      sexo: map['sexo'],
      nascimento: map['nascimento'] != null ? DateTime.tryParse(map['nascimento']) : null,
      alergias: map['alergias'],
      tipoSanguineo: map['tipo_sanguineo'],
      historicoClinico: map['historico_clinico'],
      telefone: map['telefone'],
      rua: map['rua'],
      numeroCasa: map['numero_casa'],
      bairro: map['bairro'],
      cidade: map['cidade'],
      estado: map['estado'],
      cep: map['cep'],
      nomeResponsavel: map['nome_responsavel'],
    );
  }
}