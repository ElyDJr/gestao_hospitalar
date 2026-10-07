// lib/pages/leitos/cadastrar_leito.dart
import 'package:flutter/material.dart';
import '../../domain/entities/leito.dart';
import '../../domain/services/leito_service.dart';
import '../../domain/services/ala_service.dart';
import '../../domain/entities/ala.dart';

class CadastrarLeito extends StatefulWidget {
  final LeitoService leitoService;
  final AlaService alaService;
  final Leito? leitoEdicao; // Opcional para suportar edição

  const CadastrarLeito({
    super.key,
    required this.leitoService,
    required this.alaService,
    this.leitoEdicao,
  });

  @override
  State<CadastrarLeito> createState() => _CadastrarLeitoState();
}

class _CadastrarLeitoState extends State<CadastrarLeito> {
  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController();
  
  List<Ala> _alasDisponiveis = [];
  int? _idAlaSelecionada;
  String? _tipoSelecionado;
  bool _carregando = true;

  final List<String> _tiposLeito = ['COMUM', 'PRIVADO', 'PREMIUM', 'UTI', 'ISOLAMENTO'];

  @override
  void initState() {
    super.initState();
    if (widget.leitoEdicao != null) {
      final l = widget.leitoEdicao!;
      _numeroController.text = l.numero ?? '';
      _idAlaSelecionada = l.idAla;
      _tipoSelecionado = l.tipo; 
    }
    _carregarAlas();
  }

  @override
  void dispose() {
    _numeroController.dispose();
    super.dispose();
  }

  Future<void> _carregarAlas() async {
    try {
      final alas = await widget.alaService.listarAlas();
      if (mounted) {
        setState(() {
          _alasDisponiveis = alas;
          if (_idAlaSelecionada == null && alas.isNotEmpty) {
            _idAlaSelecionada = alas.first.id;
          }
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _carregando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ERRO AO CARREGAR ALAS: $e'.toUpperCase()), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      final novoLeito = Leito(
        id: widget.leitoEdicao?.id,
        numero: _numeroController.text,
        idAla: _idAlaSelecionada,
        tipo: _tipoSelecionado ?? 'COMUM',
        situacao: widget.leitoEdicao?.situacao ?? 'VAGO',
      );

      try {
        await widget.leitoService.cadastrarLeito(novoLeito);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.leitoEdicao != null ? 'LEITO ATUALIZADO COM SUCESSO!' : 'LEITO CADASTRADO COM SUCESSO!'),
              backgroundColor: Colors.teal,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ERRO AO SALVAR: $e'.toUpperCase()), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdicao = widget.leitoEdicao != null;

    return Container(
      height: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: _carregando 
        ? const Center(child: CircularProgressIndicator(color: Colors.teal))
        : Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cabeçalho
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdicao ? "EDITAR LEITO" : "NOVO LEITO",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),

                // Formulário com Scroll
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _numeroController,
                          decoration: const InputDecoration(
                            labelText: 'NÚMERO DO LEITO (EX: 101-A) *',
                            prefixIcon: Icon(Icons.bed),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value!.isEmpty ? 'INFORME O NÚMERO DO LEITO' : null,
                        ),
                        const SizedBox(height: 16),
                        
                        // Dropdown de Tipo de Leito
                        DropdownButtonFormField<String>(
                          initialValue: _tipoSelecionado,
                          decoration: const InputDecoration(
                            labelText: 'TIPO DO LEITO *',
                            prefixIcon: Icon(Icons.category),
                            border: OutlineInputBorder(),
                          ),
                          items: _tiposLeito.map((tipo) {
                            return DropdownMenuItem<String>(
                              value: tipo,
                              child: Text(tipo),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _tipoSelecionado = val),
                          validator: (value) => value == null ? 'SELECIONE O TIPO DO LEITO' : null,
                        ),
                        const SizedBox(height: 16),
                        
                        // Dropdown Dinâmico de Ala
                        DropdownButtonFormField<int>(
                          initialValue: _idAlaSelecionada,
                          decoration: const InputDecoration(
                            labelText: 'SELECIONE A ALA *',
                            prefixIcon: Icon(Icons.apartment),
                            border: OutlineInputBorder(),
                          ),
                          items: _alasDisponiveis.map((ala) {
                            return DropdownMenuItem<int>(
                              value: ala.id,
                              child: Text("${ala.nomeAla} - ${ala.andar ?? ''}".toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _idAlaSelecionada = val),
                          validator: (value) => value == null ? 'SELECIONE A ALA' : null,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Botão de Salvar
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEdicao ? Colors.blue : Colors.teal,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  icon: Icon(isEdicao ? Icons.update : Icons.save),
                  label: Text(isEdicao ? "ATUALIZAR LEITO" : "SALVAR LEITO", style: const TextStyle(fontSize: 16)),
                  onPressed: _salvar,
                ),
              ],
            ),
          ),
    );
  }
}