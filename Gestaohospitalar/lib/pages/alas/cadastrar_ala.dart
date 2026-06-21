import 'package:flutter/material.dart';
import '../../domain/entities/ala.dart';
import '../../domain/services/ala_service.dart';

class CadastrarAla extends StatefulWidget {
  final AlaService service;
  final Ala? alaEdicao; // Se for nulo é Cadastro, se tiver dados é Edição

  const CadastrarAla({super.key, required this.service, this.alaEdicao});

  @override
  State<CadastrarAla> createState() => _CadastrarAlaState();
}

class _CadastrarAlaState extends State<CadastrarAla> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _andarCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Se estiver editando, preenche os campos
    if (widget.alaEdicao != null) {
      _nomeCtrl.text = widget.alaEdicao!.nomeAla;
      _andarCtrl.text = widget.alaEdicao!.andar;
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _andarCtrl.dispose();
    super.dispose();
  }

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      final novaAla = Ala(
        id: widget.alaEdicao?.id, // Mantém o ID se for edição
        nomeAla: _nomeCtrl.text,
        andar: _andarCtrl.text,
      );

      try {
        await widget.service.salvarAla(novaAla);
        
        if (mounted) {
          Navigator.pop(context, true); // Fecha o formulário
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.alaEdicao == null ? 'Ala cadastrada com sucesso!' : 'Ala atualizada!'),
              backgroundColor: widget.alaEdicao == null ? Colors.teal : Colors.blue,
            )
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdicao = widget.alaEdicao != null;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(isEdicao ? Icons.edit : Icons.domain, color: Colors.teal, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      isEdicao ? "Editar Ala" : "Cadastrar Nova Ala",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nomeCtrl,
              decoration: const InputDecoration(
                labelText: 'Nome da Ala (Ex: UTI, Pediatria) *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_hospital),
              ),
              validator: (value) => value!.isEmpty ? 'Informe o nome da ala' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _andarCtrl,
              decoration: const InputDecoration(
                labelText: 'Andar / Localização (Ex: 2º Andar, Térreo) *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.layers),
              ),
              validator: (value) => value!.isEmpty ? 'Informe o andar' : null,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEdicao ? Colors.blue : Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  onPressed: _salvar,
                  child: Text(isEdicao ? 'Atualizar Ala' : 'Salvar Ala'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}