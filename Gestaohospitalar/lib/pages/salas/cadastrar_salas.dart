// lib/pages/salas/cadastrar_salas.dart
import 'package:flutter/material.dart';
import '../../../domain/entities/sala.dart';
import '../../../domain/services/sala_service.dart';
import '../../../domain/services/ala_service.dart'; 
import '../../../domain/entities/ala.dart';         

class CadastrarSalas extends StatefulWidget {
  final SalaService salaService;
  final AlaService alaService; 
  final Sala? salaEdicao;

  const CadastrarSalas({
    super.key, 
    required this.salaService, 
    required this.alaService, 
    this.salaEdicao
  });

  @override
  State<CadastrarSalas> createState() => _CadastrarSalasState();
}

class _CadastrarSalasState extends State<CadastrarSalas> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();

  // Estados para carregar ala e o tipo da sala por dropdown
  List<Ala> _alasDisponiveis = [];
  int? _idAlaSelecionada;
  String? _tipoSalaSelecionado;
  bool _carregando = true;

  final List<String> _tiposSala = [
    'CONSULTÓRIO', 
    'EXAME', 
    'CIRÚRGICA', 
    'EMERGÊNCIA', 
    'REPOUSO', 
    'ENFERMARIA'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.salaEdicao != null) {
      final s = widget.salaEdicao!;
      _nomeController.text = s.nomeSala ?? '';
      _tipoSalaSelecionado = s.tipo;
      // Descomente abaixo se sua entidade Sala possuir idAla:
      // _idAlaSelecionada = s.idAla;
    }
    _carregarAlas();
  }

  @override
  void dispose() {
    _nomeController.dispose();
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
          SnackBar(content: Text("ERRO AO CARREGAR ALAS: $e".toUpperCase()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final sala = Sala(
        id: widget.salaEdicao?.id,
        tipo: _tipoSalaSelecionado ?? 'CONSULTÓRIO',
        nomeSala: _nomeController.text,
        // idAla: _idAlaSelecionada, // Descomente caso sua entidade Sala receba o id da ala
      );
      
      await widget.salaService.salvar(sala);
      
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.salaEdicao != null ? 'SALA ATUALIZADA COM SUCESSO!' : 'SALA CADASTRADA COM SUCESSO!'),
            backgroundColor: Colors.teal,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("ERRO AO SALVAR: $e".toUpperCase()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdicao = widget.salaEdicao != null;

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
                // Cabeçalho do Painel Lateral
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdicao ? "EDITAR SALA" : "NOVA SALA",
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

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nomeController,
                          decoration: const InputDecoration(
                            labelText: 'NOME DA SALA *',
                            prefixIcon: Icon(Icons.meeting_room),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v!.isEmpty ? 'INFORME O NOME DA SALA' : null,
                        ),
                        const SizedBox(height: 16),
                        
                        // Dropdown de Tipo de Sala
                        DropdownButtonFormField<String>(
                          initialValue: _tipoSalaSelecionado,
                          decoration: const InputDecoration(
                            labelText: 'TIPO DA SALA *',
                            prefixIcon: Icon(Icons.category),
                            border: OutlineInputBorder(),
                          ),
                          items: _tiposSala.map((tipo) {
                            return DropdownMenuItem<String>(
                              value: tipo,
                              child: Text(tipo),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _tipoSalaSelecionado = val),
                          validator: (value) => value == null ? 'SELECIONE O TIPO DA SALA' : null,
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
                  label: Text(isEdicao ? "ATUALIZAR SALA" : "SALVAR SALA", style: const TextStyle(fontSize: 16)),
                  onPressed: _salvar,
                ),
              ],
            ),
          ),
    );
  }
}