import 'package:flutter/material.dart';
import '../../../domain/entities/sala.dart';
import '../../../domain/services/sala_service.dart';

class CadastrarSalas extends StatefulWidget {
  final SalaService salaService;
  final Sala? salaEdicao; // Parâmetro opcional para edição

  const CadastrarSalas({super.key, required this.salaService, this.salaEdicao});

  @override
  State<CadastrarSalas> createState() => _CadastrarSalasState();
}

class _CadastrarSalasState extends State<CadastrarSalas> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _tipoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.salaEdicao != null) {
      _nomeController.text = widget.salaEdicao!.nomeSala ?? '';
      _tipoController.text = widget.salaEdicao!.tipo ?? '';
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final sala = Sala(
        id: widget.salaEdicao?.id, // Mantém o ID se for edição
        tipo: _tipoController.text,
        nomeSala: _nomeController.text,
      );
      
      await widget.salaService.salvar(sala);
      
      if (mounted) Navigator.pop(context, true); // Retorna true para atualizar lista
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao salvar: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.salaEdicao == null ? 'Nova Sala' : 'Editar Sala')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome da Sala'),
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 20),
              TextFormField( // Campo adicionado
                controller: _tipoController,
                decoration: const InputDecoration(labelText: 'Tipo (ex: Consultório, Exame)'),
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              ElevatedButton(onPressed: _salvar, child: const Text('Salvar'))
            ],
          ),
        ),
      ),
    );
  }
}