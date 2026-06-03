// lib/pages/convenios/listar_convenio.dart
import 'package:flutter/material.dart';
import '../../../domain/services/convenio_service.dart';
import '../../../domain/entities/convenio.dart';
import 'cadastrar_convenio.dart';

class ListarConvenio extends StatefulWidget {
  final ConvenioService service;

  const ListarConvenio({super.key, required this.service});

  @override
  State<ListarConvenio> createState() => _ListarConvenioState();
}

class _ListarConvenioState extends State<ListarConvenio> {
  final TextEditingController _buscaCtrl = TextEditingController();
  String _termoBusca = '';

  @override
  void initState() {
    super.initState();
    widget.service.carregarConvenios();
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  void _abrirFormularioCadastro({Convenio? convenioParaEditar}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CadastrarConvenio(
        service: widget.service,
        convenioEdicao: convenioParaEditar,
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

        // 🔍 Filtra reativamente por nome do convênio
        final listaFiltrada = widget.service.convenios.where((c) {
          final nome = c.nomeConvenio?.toLowerCase() ?? '';
          final busca = _termoBusca.toLowerCase();
          return nome.contains(busca);
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text("Convênios Parceiros"),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  controller: _buscaCtrl,
                  onChanged: (valor) {
                    setState(() {
                      _termoBusca = valor;
                    });
                  },
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: "Buscar convênio por nome...",
                    fillColor: Colors.white,
                    filled: true,
                    prefixIcon: const Icon(Icons.search, color: Colors.teal),
                    suffixIcon: _termoBusca.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _buscaCtrl.clear();
                              setState(() {
                                _termoBusca = '';
                              });
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
            label: const Text("Novo Convênio", style: TextStyle(color: Colors.white)),
          ),
          body: listaFiltrada.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off, size: 60, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        _termoBusca.isEmpty 
                            ? "Nenhum convênio parceiro encontrado." 
                            : "Nenhum convênio encontrado para '$_termoBusca'.", 
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: listaFiltrada.length,
                  itemBuilder: (context, i) {
                    final c = listaFiltrada[i];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: Icon(Icons.business, color: Colors.white),
                        ),
                        title: Text(c.nomeConvenio ?? 'Sem Nome', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Acomodação: ${c.tipoLeito} | Cobertura: ${c.percentualCobertura ?? 100}%"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              tooltip: "Editar Convênio",
                              onPressed: () => _abrirFormularioCadastro(convenioParaEditar: c),
                            ),
                            IconButton(
                              icon: const Icon(Icons.archive_outlined, color: Colors.orange),
                              tooltip: "Arquivar Convênio",
                              onPressed: () async {
                                final confirmar = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Arquivar Convênio?"),
                                    content: Text("O convênio ${c.nomeConvenio} ficará inativo no sistema."),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text("Arquivar"),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmar == true) {
                                  await widget.service.arquivarConvenio(c);
                                  
                                  // ✅ MENSAGEM DE ARQUIVAMENTO AQUI
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('${c.nomeConvenio} foi arquivado!'), backgroundColor: Colors.orange)
                                    );
                                  }
                                }
                              },
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