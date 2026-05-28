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
}