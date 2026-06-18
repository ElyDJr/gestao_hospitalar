// lib/domain/entities/almoxarifado.dart
import 'entitie.dart';

class Almoxarifado extends Entitie {
  String nome;
  String? categoria;
  String? descricao;
  int quantidade;
  String? unidade;
  double valorUnitario;
  int estoqueMinimo;
  String? lote;
  DateTime? validade;
  
  // NOVOS CAMPOS EXCLUSIVOS (Não vão no toMap)
  String? principioAtivo;
  String? contraindicacoes;

  Almoxarifado({
    super.id, 
    required this.nome,
    this.categoria,
    this.descricao,
    this.quantidade = 0,
    this.unidade,
    required this.valorUnitario,
    required this.estoqueMinimo,
    this.lote,
    this.validade,
    this.principioAtivo,
    this.contraindicacoes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_almoxarifado': id,
      'nome': nome,
      'categoria': categoria,
      'descricao': descricao,
      'quantidade': quantidade,
      'unidade': unidade,
      'valor_unitario': valorUnitario,
      'estoque_minimo': estoqueMinimo,
      'lote': lote,
      'validade': validade?.toIso8601String(),
      // NÃO COLOQUE OS NOVOS CAMPOS AQUI.
    };
  }

  factory Almoxarifado.fromMap(Map<String, dynamic> map) {
    return Almoxarifado(
      id: map['id_almoxarifado'],
      nome: map['nome'],
      categoria: map['categoria'],
      descricao: map['descricao'],
      quantidade: map['quantidade'] ?? 0,
      unidade: map['unidade'],
      valorUnitario: map['valor_unitario'] != null ? (map['valor_unitario'] as num).toDouble() : 0.0,
      estoqueMinimo: map['estoque_minimo'] ?? 0,
      lote: map['lote'],
      validade: map['validade'] != null ? DateTime.tryParse(map['validade']) : null,
    );
  }
}