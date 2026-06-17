// lib/pages/almoxarifado/listar_almoxarifado.dart
import 'package:flutter/material.dart';
import '../../../domain/services/almoxarifado_service.dart';
import '../../../domain/entities/almoxarifado.dart';
import 'cadastrar_almoxarifado.dart';

class ListarAlmoxarifado extends StatefulWidget {
  final AlmoxarifadoService service;
  
  const ListarAlmoxarifado({super.key, required this.service});

  @override
  State<ListarAlmoxarifado> createState() => _ListarAlmoxarifadoState();
}

class _ListarAlmoxarifadoState extends State<ListarAlmoxarifado> {
  final TextEditingController _buscaCtrl = TextEditingController();
  String _termoBusca = '';

  @override
  void initState() {
    super.initState();
    widget.service.carregarItens();
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  void _abrirFormularioCadastro({Almoxarifado? itemParaEditar}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CadastrarAlmoxarifado(
        service: widget.service,
        itemEdicao: itemParaEditar,
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
            body: Center(child: CircularProgressIndicator(color: Colors.teal)),
          );
        }

        final listaFiltrada = widget.service.itens.where((i) {
          final nome = i.nome.toLowerCase();
          final busca = _termoBusca.toLowerCase();
          return nome.contains(busca);
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text("Controle de Estoque"),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  controller: _buscaCtrl,
                  onChanged: (valor) => setState(() => _termoBusca = valor),
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: "Buscar item por nome...",
                    fillColor: Colors.white,
                    filled: true,
                    prefixIcon: const Icon(Icons.search, color: Colors.teal),
                    suffixIcon: _termoBusca.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _buscaCtrl.clear();
                              setState(() => _termoBusca = '');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
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
            label: const Text("Novo Item", style: TextStyle(color: Colors.white)),
          ),
          body: listaFiltrada.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        _termoBusca.isEmpty
                            ? "Nenhum item cadastrado no almoxarifado."
                            : "Nenhum item encontrado para '$_termoBusca'.",
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: listaFiltrada.length,
                  itemBuilder: (context, i) {
                    final item = listaFiltrada[i];
                    final bool estoqueBaixo = item.quantidade <= item.estoqueMinimo;

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: estoqueBaixo ? Colors.red.shade100 : Colors.teal.shade100,
                          child: Icon(Icons.inventory, color: estoqueBaixo ? Colors.red : Colors.teal),
                        ),
                        title: Text(item.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Cat: ${item.categoria} | Qtd: ${item.quantidade} | Min: ${item.estoqueMinimo}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          tooltip: "Editar Item",
                          onPressed: () => _abrirFormularioCadastro(itemParaEditar: item),
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