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

  // Opções para o tipo de ala
  final List<String> _tiposAla = ['COMUM', 'PRIVADO', 'PREMIUM'];
  String? _tipoSelecionado = 'COMUM'; // Valor padrão inicial

  @override
  void initState() {
    super.initState();
    // Se estiver editando, preenche os campos
    if (widget.alaEdicao != null) {
      _nomeCtrl.text = widget.alaEdicao!.nomeAla;
      _andarCtrl.text = widget.alaEdicao!.andar;
      
      // Carrega o tipo selecionado se ele existir na entidade
      if (widget.alaEdicao!.tipo != null && _tiposAla.contains(widget.alaEdicao!.tipo)) {
        _tipoSelecionado = widget.alaEdicao!.tipo;
      }
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
      id: widget.alaEdicao?.id,
      nomeAla: _nomeCtrl.text,
      andar: _andarCtrl.text,
      tipo: _tipoSelecionado ?? 'COMUM', // 👈 Adicione o ?? 'COMUM' aqui!
    );

    try {
      await widget.service.salvarAla(novaAla);
      
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.alaEdicao == null
                  ? 'Ala cadastrada com sucesso!'
                  : 'Ala atualizada!',
            ),
            backgroundColor:
                widget.alaEdicao == null ? Colors.teal : Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final isEdicao = widget.alaEdicao != null;

    return Padding(
      // Garante que o formulário suba quando o teclado abrir
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cabeçalho
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isEdicao ? Icons.edit : Icons.domain,
                          color: Colors.teal,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isEdicao ? "Editar Ala" : "Cadastrar Nova Ala",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),

                // Campo: Nome da Ala
                TextFormField(
                  controller: _nomeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nome da Ala (Ex: UTI, Pediatria) *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.local_hospital),
                  ),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty)
                          ? 'Informe o nome da ala'
                          : null,
                ),
                const SizedBox(height: 16),

                // Campo: Andar / Localização
                TextFormField(
                  controller: _andarCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Andar / Localização (Ex: 2º Andar, Térreo) *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.layers),
                  ),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty)
                          ? 'Informe o andar'
                          : null,
                ),
                const SizedBox(height: 16),

                // Campo Seleção: Tipo de Ala
                DropdownButtonFormField<String>(
                  value: _tipoSelecionado,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Ala *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.star_outline),
                  ),
                  items: _tiposAla.map((String tipo) {
                    return DropdownMenuItem<String>(
                      value: tipo,
                      child: Text(tipo),
                    );
                  }).toList(),
                  onChanged: (String? novoValor) {
                    setState(() {
                      _tipoSelecionado = novoValor;
                    });
                  },
                  validator: (value) =>
                      (value == null || value.isEmpty)
                          ? 'Selecione o tipo da ala'
                          : null,
                ),

                const SizedBox(height: 24),

                // Botões Ação
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancelar"),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEdicao ? Colors.blue : Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                      onPressed: _salvar,
                      child: Text(isEdicao ? 'Atualizar Ala' : 'Salvar Ala'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}