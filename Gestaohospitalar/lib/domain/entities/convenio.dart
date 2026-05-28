import 'entitie.dart';

class Convenio extends Entitie {
  String? nomeConvenio;
  String? tipoLeito;
  bool cobreInternacao;
  bool cobreExames;
  bool cobreCirurgia;
  double? limiteMedicamento;
  double? percentualCobertura;

  Convenio({
    super.id, // Corresponde ao id_convenio
    this.nomeConvenio,
    this.tipoLeito,
    this.cobreInternacao = true,
    this.cobreExames = true,
    this.cobreCirurgia = true,
    this.limiteMedicamento,
    this.percentualCobertura,
  });
}