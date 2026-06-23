// lib/pages/almoxarifado/cadastrar_almoxarifado.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../domain/services/almoxarifado_service.dart';
import '../../../domain/entities/almoxarifado.dart';

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
  
  // ADICIONADO: Controladores para Lote e Validade
  final _loteCtrl = TextEditingController();
  final _validadeCtrl = TextEditingController();
  DateTime? _dataValidade;
  
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
      
      // ADICIONADO: Carregar Lote e Validade se for edição
      _loteCtrl.text = i.lote ?? '';
      if (i.validade != null) {
        _dataValidade = i.validade;
        _validadeCtrl.text = "${_dataValidade!.day.toString().padLeft(2, '0')}/${_dataValidade!.month.toString().padLeft(2, '0')}/${_dataValidade!.year}";
      }

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
    // ADICIONADO: Limpeza dos novos controladores
    _loteCtrl.dispose();
    _validadeCtrl.dispose();
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
                    
                    DropdownButtonFormField<String>(
                      initialValue: _categoriaSelecionada, 
                      hint: const Text("Selecione uma categoria"),
                      decoration: const InputDecoration(labelText: "Categoria *", border: OutlineInputBorder()),
                      items: const ['MEDICAMENTO', 'DESCARTAVEL', 'LIMPEZA', 'EPI', 'INSUMO']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
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
                            decoration: const InputDecoration(
                              labelText: "Estoque Mínimo *",
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return "Obrigatório";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // ADICIONADO: Linha com Lote e Validade
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _loteCtrl,
                            decoration: const InputDecoration(labelText: "Lote", border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _validadeCtrl,
                            readOnly: true, // Impede digitação manual para forçar o seletor
                            decoration: const InputDecoration(
                              labelText: "Validade", 
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: _dataValidade ?? DateTime.now(),
                                firstDate: DateTime.now().subtract(const Duration(days: 365 * 10)), // 10 anos no passado (caso cadastre algo retroativo)
                                lastDate: DateTime.now().add(const Duration(days: 365 * 20)), // 20 anos no futuro
                              );
                              
                              if (pickedDate != null) {
                                setState(() {
                                  _dataValidade = pickedDate;
                                  _validadeCtrl.text = "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                                });
                              }
                            },
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
                          estoqueMinimo: int.parse(_estoqueMinimoCtrl.text), 
                          valorUnitario: double.tryParse(_valorUnitarioCtrl.text.replaceAll(',', '.')) ?? 0.0,
                          
                          // ADICIONADO: Enviando o Lote e Validade para a Entidade
                          lote: _loteCtrl.text.trim().isEmpty ? null : _loteCtrl.text.trim(),
                          validade: _dataValidade,
                          
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