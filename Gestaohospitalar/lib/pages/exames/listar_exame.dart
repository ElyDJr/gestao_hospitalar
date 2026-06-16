import 'package:flutter/material.dart';
import '../../../domain/services/exame_service.dart';
import '../../../domain/entities/exame.dart';
import 'cadastrar_exame.dart';

class ListarExame extends StatefulWidget {
  // A variável service é obrigatória
  final ExameService service;

  const ListarExame({super.key, required this.service});

  @override
  State<ListarExame> createState() => _ListarExameState();
}

class _ListarExameState extends State<ListarExame> {
  final TextEditingController _buscaCtrl = TextEditingController();
  String _termoBusca = '';

  @override
  void initState() {
    super.initState();
    // Chamada inicial para carregar dados
    widget.service.carregarExames();
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  void _abrirFormularioCadastro({Exame? exameParaEditar}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CadastrarExame(
        service: widget.service,
        exameEdicao: exameParaEditar,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.service,
      builder: (context, _) {
        if (widget.service.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.teal,)),
          );
        }

        final listaFiltrada = widget.service.exames.where((e) {
          final nome = e.nome.toLowerCase();
          final busca = _termoBusca.toLowerCase();
          return nome.contains(busca);
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text("Catálogo de Exames"),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  controller: _buscaCtrl,
                  onChanged: (valor) => setState(() => _termoBusca = valor),
                  decoration: InputDecoration(
                    hintText: "Buscar exame por nome...",
                    fillColor: Colors.white,
                    filled: true,
                    prefixIcon: const Icon(Icons.search, color: Colors.teal,),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _abrirFormularioCadastro(),
            backgroundColor:Colors.teal,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("Novo Exame", style: TextStyle(color: Colors.white)),
          ),
          body: listaFiltrada.isEmpty
              ? const Center(child: Text("Nenhum exame cadastrado."))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: listaFiltrada.length,
                  itemBuilder: (context, i) {
                    final exame = listaFiltrada[i];
                    return Card(
                      child: ListTile(
                        title: Text(exame.nome),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _abrirFormularioCadastro(exameParaEditar: exame),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}