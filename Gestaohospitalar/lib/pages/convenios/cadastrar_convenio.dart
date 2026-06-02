// lib/pages/convenios/cadastrar_convenio.dart
import 'package:flutter/material.dart';
import '../../../domain/services/convenio_service.dart';
import '../../../domain/entities/convenio.dart';

class CadastrarConvenio extends StatefulWidget {
  final ConvenioService service;
  final Convenio? convenioEdicao;

  const CadastrarConvenio({super.key, required this.service, this.convenioEdicao});

  @override
  State<CadastrarConvenio> createState() => _CadastrarConvenioState();
}

class _CadastrarConvenioState extends State<CadastrarConvenio> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _limiteCtrl = TextEditingController();
  final _coberturaCtrl = TextEditingController();
  
  String _tipoLeitoSelecionado = 'COMUM';
  bool _cobreInternacao = true;
  bool _cobreExames = true;
  bool _cobreCirurgia = true;

  @override
  void initState() {
    super.initState();
    if (widget.convenioEdicao != null) {
      final c = widget.convenioEdicao!;
      _nomeCtrl.text = c.nomeConvenio ?? '';
      _limiteCtrl.text = c.limiteMedicamento?.toString() ?? '';
      _coberturaCtrl.text = c.percentualCobertura?.toString() ?? '';
      _tipoLeitoSelecionado = c.tipoLeito ?? 'COMUM';
      _cobreInternacao = c.cobreInternacao;
      _cobreExames = c.cobreExames;
      _cobreCirurgia = c.cobreCirurgia;
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _limiteCtrl.dispose();
    _coberturaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdicao = widget.convenioEdicao != null;
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(isEdicao ? Icons.edit : Icons.business, color: Colors.teal, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      isEdicao ? "Editar Convênio" : "Cadastro de Convênio",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))
              ],
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nomeCtrl,
                      decoration: const InputDecoration(labelText: "Nome do Convênio *", border: OutlineInputBorder()),
                      validator: (v) => v == null || v.isEmpty ? "Obrigatório" : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _tipoLeitoSelecionado, // Corrigido deprecation!
                      decoration: const InputDecoration(labelText: "Tipo de Leito Coberto", border: OutlineInputBorder()),
                      items: const ['COMUM', 'PRIVADO', 'PREMIUM']
                          .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (v) => setState(() => _tipoLeitoSelecionado = v!),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text("Cobre Internação"),
                      value: _cobreInternacao,
                      onChanged: (v) => setState(() => _cobreInternacao = v),
                    ),
                    SwitchListTile(
                      title: const Text("Cobre Exames"),
                      value: _cobreExames,
                      onChanged: (v) => setState(() => _cobreExames = v),
                    ),
                    SwitchListTile(
                      title: const Text("Cobre Cirurgia"),
                      value: _cobreCirurgia,
                      onChanged: (v) => setState(() => _cobreCirurgia = v),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _limiteCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: "Limite Medicamento (R\$)", border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _coberturaCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: "Cobertura (%)", border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final novoConvenio = Convenio(
                          id: widget.convenioEdicao?.id,
                          ativo: widget.convenioEdicao?.ativo ?? 1,
                          nomeConvenio: _nomeCtrl.text,
                          tipoLeito: _tipoLeitoSelecionado,
                          cobreInternacao: _cobreInternacao,
                          cobreExames: _cobreExames,
                          cobreCirurgia: _cobreCirurgia,
                          limiteMedicamento: double.tryParse(_limiteCtrl.text),
                          percentualCobertura: double.tryParse(_coberturaCtrl.text),
                        );
                        await widget.service.salvarConvenio(novoConvenio);
                        if (context.mounted) Navigator.pop(context);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red));
                        }
                      }
                    }
                  },
                  child: const Text("Salvar Convênio"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}