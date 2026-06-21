import 'package:flutter/material.dart';
import '../../domain/entities/leito.dart';
import '../../domain/services/leito_service.dart';
import '../../domain/services/ala_service.dart';
import '../../domain/entities/ala.dart';

class CadastrarLeito extends StatefulWidget {
  final LeitoService leitoService;
  final AlaService alaService; // Adicionado para carregar as alas

  const CadastrarLeito({
    super.key,
    required this.leitoService,
    required this.alaService
  });

  @override
  State<CadastrarLeito> createState() => _CadastrarLeitoState();
}

class _CadastrarLeitoState extends State<CadastrarLeito> {
  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController();
  
  // Estado para os dados
  List<Ala> _alasDisponiveis = [];
  int? _idAlaSelecionada;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarAlas();
  }

  Future<void> _carregarAlas() async {
    try {
      final alas = await widget.alaService.listarAlas();
      if (mounted) {
        setState(() {
          _alasDisponiveis = alas;
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _carregando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar alas: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      // Aqui você ajusta para salvar o ID da ala
      final novoLeito = Leito(
        numero: _numeroController.text,
        idAla: _idAlaSelecionada, // Certifique-se que sua entidade Leito tenha este campo
        situacao: 'VAGO',
      );

      try {
        await widget.leitoService.cadastrarLeito(novoLeito);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Leito cadastrado com sucesso!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Leito'),
        backgroundColor: const Color.fromRGBO(0, 150, 136, 1),
        foregroundColor: Colors.white,
      ),
      body: _carregando 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _numeroController,
                    decoration: const InputDecoration(
                      labelText: 'Número do Leito (Ex: 101-A)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value!.isEmpty ? 'Informe o número' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // Dropdown Dinâmico
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Selecione a Ala',
                      border: OutlineInputBorder(),
                    ),
                    value: _idAlaSelecionada,
                    items: _alasDisponiveis.map((ala) {
                      return DropdownMenuItem<int>(
                        value: ala.id,
                        child: Text("${ala.nomeAla} - ${ala.andar}"),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _idAlaSelecionada = val),
                    validator: (value) => value == null ? 'Selecione a Ala' : null,
                  ),
                  
                  const Spacer(),
                  
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal, 
                      foregroundColor: Colors.white, 
                      padding: const EdgeInsets.symmetric(vertical: 16)
                    ),
                    onPressed: _salvar,
                    child: const Text('Salvar Leito', style: TextStyle(fontSize: 16)),
                  )
                ],
              ),
            ),
          ),
    );
  }
}