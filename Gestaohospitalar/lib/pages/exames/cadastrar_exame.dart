import 'package:flutter/material.dart';
import '../../domain/services/exame_service.dart';
import '../../domain/entities/exame.dart';

class CadastrarExame extends StatefulWidget {
  // Parâmetros opcionais (com '?') para funcionar tanto na Dashboard quanto na Lista
  final ExameService? service;
  final Exame? exameEdicao;

  const CadastrarExame({super.key, this.service, this.exameEdicao});

  @override
  State<CadastrarExame> createState() => _CadastrarExameState();
}

class _CadastrarExameState extends State<CadastrarExame> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _valorCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  
  late ExameService _service;

  @override
  void initState() {
    super.initState();
    // Se a tela anterior passou um serviço (como na lista), usamos ele. 
    // Se não passou (como na Dashboard), criamos um novo.
    _service = widget.service ?? ExameService();

    // Se estiver editando, preenche os campos com os dados antigos
    if (widget.exameEdicao != null) {
      _nomeCtrl.text = widget.exameEdicao!.nome;
      _valorCtrl.text = widget.exameEdicao!.valor?.toString() ?? '';
      _descCtrl.text = widget.exameEdicao!.descricao ?? '';
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _valorCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      // Troca vírgula por ponto para evitar erros no banco de dados
      final valorTratado = double.tryParse(_valorCtrl.text.replaceAll(',', '.'));

      final exame = Exame(
        id: widget.exameEdicao?.id, // Mantém o ID se for edição
        nome: _nomeCtrl.text,
        valor: valorTratado,
        descricao: _descCtrl.text,
      );
      
      await _service.salvarExame(exame);
      
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.exameEdicao == null ? 'Exame cadastrado com sucesso!' : 'Exame atualizado com sucesso!'),
            backgroundColor:  const Color.fromRGBO(0, 150, 136, 1),
          )
        );
        Navigator.pop(context, true); // Retorna e atualiza a lista
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exameEdicao == null ? 'Cadastrar Exame' : 'Editar Exame'),
        backgroundColor: const Color.fromRGBO(0, 150, 136, 1),
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
                controller: _nomeCtrl, 
                decoration: const InputDecoration(labelText: 'Nome do Exame *'),
                validator: (v) => v!.isEmpty ? 'Informe o nome do exame' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valorCtrl, 
                decoration: const InputDecoration(labelText: 'Valor (R\$)', prefixText: 'R\$ '), 
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl, 
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.exameEdicao == null ? const Color.fromRGBO(0, 150, 136, 1): const Color.fromARGB(255, 33, 150, 243),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _salvar,
                child: Text(
                  widget.exameEdicao == null ? 'Salvar Exame' : 'Atualizar Exame', 
                  style: const TextStyle(fontSize: 16)
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}