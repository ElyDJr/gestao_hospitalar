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

  // 🔴 Diálogo de confirmação e chamada do arquivarExame
  Future<void> _excluirExame(Exame exame) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmação'),
        content: Text('Tem certeza que deseja excluir o exame "${exame.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('NÃO'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('SIM'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await widget.service.arquivarExame(exame);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Exame "${exame.nome}" excluído com sucesso!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir exame: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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
            backgroundColor: Colors.teal,
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _abrirFormularioCadastro(exameParaEditar: exame),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _excluirExame(exame),
                            ),
                          ],
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