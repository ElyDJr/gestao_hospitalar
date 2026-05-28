import 'entitie.dart';

class Paciente extends Entitie {
  String? nome;
  String? cpf;
  String? sexo;
  DateTime? nascimento;
  String? alergias;
  String? tipoSanguineo;
  String? historicoClinico;
  String? telefone;
  String? rua;
  int? numeroCasa;
  String? bairro;
  String? cidade;
  String? estado;
  String? cep;
  String? nomeResponsavel;

  Paciente({
    super.id, // Corresponde ao id_paciente
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


  // MÁGICA 1: Transforma a linha do banco de volta em Objeto Dart
  factory Paciente.fromMap(Map<String, dynamic> map) {
    return Paciente(
      id: map['id_paciente'] as int?,
      nome: map['nome'] as String?,
      cpf: map['cpf'] as String?,
      sexo: map['sexo'] as String?,
      nascimento: map['nascimento'] != null ? DateTime.parse(map['nascimento'] as String) : null,
      alergias: map['alergias'] as String?,
      tipoSanguineo: map['tipo_sanguineo'] as String?,
      historicoClinico: map['historico_clinico'] as String?,
      telefone: map['telefone'] as String?,
      rua: map['rua'] as String?,
      numeroCasa: map['numero_casa'] as int?,
      bairro: map['bairro'] as String?,
      cidade: map['cidade'] as String?,
      estado: map['estado'] as String?,
      cep: map['cep'] as String?,
      nomeResponsavel: map['nome_responsavel'] as String?,
    );
  }

  // MÁGICA 2: Transforma as variáveis do Dart em formato Map para o SQLite salvar
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id_paciente': id,
      'nome': nome,
      'cpf': cpf,
      'sexo': sexo,
      'nascimento': nascimento?.toIso8601String(),
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
}



