import 'package:flutter/material.dart';
import '../../domain/services/sala_service.dart';

class CadastrarSalas extends StatefulWidget {
  // 🟢 Corrigido para salaService para alinhar com o restante do ecossistema de salas
  final SalaService salaService; 

  const CadastrarSalas({
    super.key,
    required this.salaService,
  });

  @override
  State<CadastrarSalas> createState() => _CadastrarSalasState();
}

class _CadastrarSalasState extends State<CadastrarSalas> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _numeroController = TextEditingController();

  String? _alaSelecionada;
  String? _andarSelecionado;

  final List<String> _alas = [
    'Maternidade',
    'UTI',
    'Pediatria',
    'Cardiologia',
    'Emergência',
    'Clínica Médica',
  ];

  final List<String> _andares = [
    'Térreo',
    '1º Andar',
    '2º Andar',
    '3º Andar',
    '4º Andar',
  ];

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // 🟢 Transforma os inputs no Map esperado pelo método 'cadastrarSala' do Sqflite
      final Map<String, dynamic> novaSala = {
        'numero_sala': _numeroController.text,
        'ala': _alaSelecionada!,
        'andar': _andarSelecionado!,
        'status_sala': 'DISPONIVEL', // Define o status inicial padrão no banco
      };

      // 🟢 Envia o Map estruturado para o seu Service
      await widget.salaService.cadastrarSala(novaSala);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sala cadastrada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        // Retorna 'true' para sinalizar à tela anterior que a lista precisa ser atualizada
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cadastrar sala: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _numeroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Sala'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _numeroController,
                decoration: const InputDecoration(
                  labelText: 'Número da Sala',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o número da sala';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _alaSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Ala',
                ),
                items: _alas.map((ala) {
                  return DropdownMenuItem(
                    value: ala,
                    child: Text(ala),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _alaSelecionada = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Selecione uma ala' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _andarSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Andar',
                ),
                items: _andares.map((andar) {
                  return DropdownMenuItem(
                    value: andar,
                    child: Text(andar),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _andarSelecionado = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Selecione um andar' : null,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _salvar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Salvar Sala'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}