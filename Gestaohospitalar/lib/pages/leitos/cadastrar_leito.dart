import 'package:flutter/material.dart';
import '../../domain/entities/leito.dart';
import '../../domain/services/leito_service.dart';

class CadastrarLeito extends StatefulWidget {
  final LeitoService leitoService;
  const CadastrarLeito({super.key, required this.leitoService});

  @override
  State<CadastrarLeito> createState() => _CadastrarLeitoState();
}

class _CadastrarLeitoState extends State<CadastrarLeito> {
  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController();
  
  String? _alaSelecionada;
  String? _andarSelecionado;

  final List<String> _alas = ['Maternidade', 'UTI', 'Pediatria', 'Cardiologia', 'Emergência', 'Clínica Médica'];
  final List<String> _andares = ['Térreo', '1º Andar', '2º Andar', '3º Andar', '4º Andar'];

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      final novoLeito = Leito(
        numero: _numeroController.text,
        ala: _alaSelecionada,
        andar: _andarSelecionado,
        situacao: 'VAGO',
      );

      await widget.leitoService.cadastrarLeito(novoLeito);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leito cadastrado com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Retorna true para atualizar a lista
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Leito'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _numeroController,
                decoration: const InputDecoration(labelText: 'Número do Leito (Ex: 101-A)'),
                validator: (value) => value!.isEmpty ? 'Informe o número' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Ala Hospitalar'),
                value: _alaSelecionada,
                items: _alas.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                onChanged: (val) => setState(() => _alaSelecionada = val),
                validator: (value) => value == null ? 'Selecione a Ala' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Andar'),
                initialValue: _andarSelecionado,
                items: _andares.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                onChanged: (val) => setState(() => _andarSelecionado = val),
                validator: (value) => value == null ? 'Selecione o Andar' : null,
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
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