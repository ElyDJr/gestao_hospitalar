// lib/domain/entities/convenio.dart
import 'entitie.dart';

class Convenio extends Entitie {
  final int? ativo; // ✅ Adicionado para suporte ao Soft Delete
  final String? nomeConvenio;
  final String? tipoLeito;
  final bool cobreInternacao;
  final bool cobreExames;
  final bool cobreCirurgia;
  final double? limiteMedicamento;
  final double? percentualCobertura;

  Convenio({
    super.id, // Corresponde ao id_convenio
    this.ativo = 1,
    this.nomeConvenio,
    this.tipoLeito = 'COMUM',
    this.cobreInternacao = true,
    this.cobreExames = true,
    this.cobreCirurgia = true,
    this.limiteMedicamento,
    this.percentualCobertura,
  });

  Convenio copyWith({int? ativo}) {
    return Convenio(
      id: id,
      ativo: ativo ?? this.ativo,
      nomeConvenio: nomeConvenio,
      tipoLeito: tipoLeito,
      cobreInternacao: cobreInternacao,
      cobreExames: cobreExames,
      cobreCirurgia: cobreCirurgia,
      limiteMedicamento: limiteMedicamento,
      percentualCobertura: percentualCobertura,
    );
  }

  // ✅ Traduz de Dart para as colunas exatas do seu SQLite (Evita erro de CHECK)
  Map<String, dynamic> toMap() {
    return {
      'id_convenio': id,
      'ativo': ativo ?? 1,
      'nome_convenio': nomeConvenio,
      'tipo_leito': tipoLeito,
      'cobre_internacao': cobreInternacao ? 1 : 0, // ✅ Converte bool para int (0 ou 1)
      'cobre_exames': cobreExames ? 1 : 0,         // ✅ Converte bool para int (0 ou 1)
      'cobre_cirurgia': cobreCirurgia ? 1 : 0,     // ✅ Converte bool para int (0 ou 1)
      'limite_medicamento': limiteMedicamento,
      'percentual_cobertura': percentualCobertura,
    };
  }

  // ✅ Traduz de SQLite para objetos Dart
  factory Convenio.fromMap(Map<String, dynamic> map) {
    return Convenio(
      id: map['id_convenio'],
      ativo: map['ativo'],
      nomeConvenio: map['nome_convenio'],
      tipoLeito: map['tipo_leito'],
      cobreInternacao: map['cobre_internacao'] == 1, // ✅ Converte int para bool
      cobreExames: map['cobre_exames'] == 1,         // ✅ Converte int para bool
      cobreCirurgia: map['cobre_cirurgia'] == 1,     // ✅ Converte int para bool
      limiteMedicamento: map['limite_medicamento'] != null ? (map['limite_medicamento'] as num).toDouble() : null,
      percentualCobertura: map['percentual_cobertura'] != null ? (map['percentual_cobertura'] as num).toDouble() : null,
    );
  }
}