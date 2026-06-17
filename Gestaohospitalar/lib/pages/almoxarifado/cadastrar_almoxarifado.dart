// lib/pages/almoxarifado/cadastrar_almoxarifado.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../domain/services/almoxarifado_service.dart';
import '../../../domain/entities/almoxarifado.dart';
import '../../domain/entities/medicamento.dart';

class CadastrarAlmoxarifado extends StatefulWidget {
  final AlmoxarifadoService service;
  final Almoxarifado? itemEdicao;

  const CadastrarAlmoxarifado({super.key, required this.service, this.itemEdicao});

  @override
  State<CadastrarAlmoxarifado> createState() => _CadastrarAlmoxarifadoState();
}

class _CadastrarAlmoxarifadoState extends State<CadastrarAlmoxarifado> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  final _quantidadeCtrl = TextEditingController();
  final _valorUnitarioCtrl = TextEditingController();
  final _estoqueMinimoCtrl = TextEditingController();
  
  final _principioAtivoCtrl = TextEditingController();
  final _contraindicacoesCtrl = TextEditingController();
  
  // ALTERAÇÃO 1: Transformado em variável que aceita nulo e inicia sem valor
  String? _categoriaSelecionada; 
  
  @override
  void initState() {
    super.initState();
    if (widget.itemEdicao != null) {
      final i = widget.itemEdicao!;
      _nomeCtrl.text = i.nome;
      _descricaoCtrl.text = i.descricao ?? '';
      _quantidadeCtrl.text = i.quantidade.toString();
      _valorUnitarioCtrl.text = i.valorUnitario.toString();
      _estoqueMinimoCtrl.text = i.estoqueMinimo.toString();
      _categoriaSelecionada = i.categoria;

      // ADICIONE ISTO: Pede os dados extra se for um medicamento em edição
      if (_categoriaSelecionada == 'MEDICAMENTO') {
        widget.service.carregarDetalhesMedicamento(i).then((_) {
          if (mounted) {
            setState(() {
              _principioAtivoCtrl.text = i.principioAtivo ?? '';
              _contraindicacoesCtrl.text = i.contraindicacoes ?? '';
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _descricaoCtrl.dispose();
    _quantidadeCtrl.dispose();
    _valorUnitarioCtrl.dispose();
    _estoqueMinimoCtrl.dispose();
    _principioAtivoCtrl.dispose();
    _contraindicacoesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdicao = widget.itemEdicao != null;

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
                    Icon(isEdicao ? Icons.edit : Icons.inventory, color: Colors.teal, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      isEdicao ? "Editar Item" : "Cadastrar Item",
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
                      decoration: const InputDecoration(labelText: "Nome do Item *", border: OutlineInputBorder()),
                      validator: (v) => v == null || v.isEmpty ? "Obrigatório" : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // ALTERAÇÃO 2: Configuração do Dropdown
                    DropdownButtonFormField<String>(
                      value: _categoriaSelecionada, // Agora começa nulo
                      hint: const Text("Selecione uma categoria"), // Dica visual para o admin
                      decoration: const InputDecoration(labelText: "Categoria *", border: OutlineInputBorder()),
                      items: const ['MEDICAMENTO', 'DESCARTAVEL', 'LIMPEZA', 'EPI', 'INSUMO']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      // Obriga o usuário a selecionar algo antes de salvar
                      validator: (v) => v == null || v.isEmpty ? "Selecione a categoria do item" : null,
                      onChanged: (v) {
                        setState(() {
                          _categoriaSelecionada = v;
                          if (_categoriaSelecionada != 'MEDICAMENTO') {
                            _principioAtivoCtrl.clear();
                            _contraindicacoesCtrl.clear();
                          }
                        });
                      },
                    ),
                    
                    if (_categoriaSelecionada == 'MEDICAMENTO') ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _principioAtivoCtrl,
                        decoration: const InputDecoration(labelText: "Princípio Ativo", border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contraindicacoesCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: "Contraindicações", border: OutlineInputBorder()),
                      ),
                    ],

                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descricaoCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: "Descrição", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _quantidadeCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(labelText: "Quantidade Inicial *", border: OutlineInputBorder()),
                            validator: (v) => v == null || v.isEmpty ? "Obrigatório" : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _estoqueMinimoCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(labelText: "Estoque Mínimo", border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _valorUnitarioCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: "Valor Unitário (R\$)", border: OutlineInputBorder()),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEdicao ? Colors.blue : Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final novoItem = Almoxarifado(
                        id: widget.itemEdicao?.id,
                        nome: _nomeCtrl.text,
                        categoria: _categoriaSelecionada!, 
                        descricao: _descricaoCtrl.text,
                        quantidade: int.tryParse(_quantidadeCtrl.text) ?? 0,
                        estoqueMinimo: int.tryParse(_estoqueMinimoCtrl.text) ?? 0,
                        valorUnitario: double.tryParse(_valorUnitarioCtrl.text.replaceAll(',', '.')) ?? 0.0,
                        // ADICIONE AS DUAS LINHAS ABAIXO:
                        principioAtivo: _categoriaSelecionada == 'MEDICAMENTO' ? _principioAtivoCtrl.text : null,
                        contraindicacoes: _categoriaSelecionada == 'MEDICAMENTO' ? _contraindicacoesCtrl.text : null,
                      );
                      
                      await widget.service.salvarItem(novoItem);
                        
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isEdicao ? 'Item atualizado!' : 'Item cadastrado!'),
                              backgroundColor: isEdicao ? Colors.blue : Colors.teal,
                            )
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red));
                        }
                      }
                    }
                  },
                  child: Text(isEdicao ? "Atualizar Item" : "Salvar Item"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}