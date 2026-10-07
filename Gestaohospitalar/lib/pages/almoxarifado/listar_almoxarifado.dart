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
  String _filtroCategoria = 'TODOS';

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

  // 🔴 Função para confirmar e excluir o item
  Future<void> _excluirItem(Almoxarifado item) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmação'),
        content: Text('Tem certeza que deseja excluir "${item.nome}" do estoque?'),
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
        await widget.service.arquivarItem(item);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item.nome} excluído com sucesso!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir: $e'),
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
            body: Center(child: CircularProgressIndicator(color: Colors.teal)),
          );
        }

        final categorias = [
          'TODOS',
          ...widget.service.itens
              .map((e) => e.categoria ?? 'GERAL')
              .toSet()
              .toList()
        ];

        final listaFiltrada = widget.service.itens.where((i) {
          final nome = i.nome.toLowerCase();
          final busca = _termoBusca.toLowerCase();
          final categoriaOk = _filtroCategoria == 'TODOS' ||
              (i.categoria ?? 'GERAL') == _filtroCategoria;
          return nome.contains(busca) && categoriaOk;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text("Controle de Almoxarifado"),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(120),
              child: Column(
                children: [
                  // Campo de Busca
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  const SizedBox(height: 8),
                  // Chips de Filtro por Categoria
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: categorias.length,
                      itemBuilder: (context, index) {
                        final cat = categorias[index];
                        final selecionado = cat == _filtroCategoria;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(
                              cat,
                              style: TextStyle(
                                color: selecionado ? Colors.teal : Colors.white,
                                fontWeight: selecionado
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            selected: selecionado,
                            backgroundColor: Colors.teal.shade700,
                            selectedColor: Colors.white,
                            onSelected: (val) {
                              setState(() => _filtroCategoria = cat);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
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
                      const Icon(Icons.inventory_2_outlined,
                          size: 60, color: Colors.grey),
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
                  padding: const EdgeInsets.all(16),
                  itemCount: listaFiltrada.length,
                  itemBuilder: (context, i) {
                    final item = listaFiltrada[i];
                    final bool estoqueBaixo =
                        item.quantidade <= item.estoqueMinimo;

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: estoqueBaixo
                                ? Colors.red.shade100
                                : Colors.teal.shade100,
                            child: Icon(
                              item.categoria?.toUpperCase() == 'MEDICAMENTO'
                                  ? Icons.medication
                                  : Icons.inventory_2,
                              color: estoqueBaixo ? Colors.red : Colors.teal,
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.nome,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              if (estoqueBaixo)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    "ESTOQUE BAIXO",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Categoria: ${item.categoria ?? 'GERAL'} | Un: ${item.unidade ?? 'UN'}",
                                  style: const TextStyle(fontSize: 13),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Qtd em estoque: ${item.quantidade} (Mín: ${item.estoqueMinimo})",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: estoqueBaixo
                                        ? Colors.red.shade700
                                        : Colors.grey.shade700,
                                    fontWeight: estoqueBaixo
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 🔵 Botão Editar
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                tooltip: "Editar Item",
                                onPressed: () => _abrirFormularioCadastro(
                                  itemParaEditar: item,
                                ),
                              ),
                              // 🔴 Botão Excluir
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: "Excluir Item",
                                onPressed: () => _excluirItem(item),
                              ),
                            ],
                          ),
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