// lib/pages/salas/listar_salas.dart
import 'package:flutter/material.dart';
import '../../../domain/services/sala_service.dart';
import '../../../domain/services/ala_service.dart'; // 🟢 Import necessário para o AlaService
import '../../../domain/entities/sala.dart';
import 'cadastrar_salas.dart';

class ListarSalas extends StatefulWidget {
  final SalaService service;
  final AlaService alaService; // 🟢 Injetado ou criado na instância

  const ListarSalas({
    super.key, 
    required this.service,
    required this.alaService,
  });

  @override
  State<ListarSalas> createState() => _ListarSalasState();
}

class _ListarSalasState extends State<ListarSalas> {
  final TextEditingController _buscaCtrl = TextEditingController();
  String _termoBusca = '';

  List<Sala> _salas = [];
  bool _carregando = true;
  String? _erroAviso;

  @override
  void initState() {
    super.initState();
    _carregarSalas();
  }

  Future<void> _carregarSalas() async {
    if (!mounted) return;
    
    setState(() { 
      _carregando = true; 
      _erroAviso = null; 
    });

    try {
      final lista = await widget.service.listarTodas();
      
      if (mounted) {
        setState(() {
          _salas = lista;
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _carregando = false;
          _erroAviso = "ERRO AO CARREGAR SALAS: ${e.toString()}".toUpperCase();
        });
      }
    }
  }

  // 🟢 Ajustado para abrir o formulário passando tanto o salaService quanto o alaService
  void _abrirFormulario({Sala? salaEdicao}) async {
    final atualizou = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CadastrarSalas(
        salaService: widget.service,
        alaService: widget.alaService, // 🟢 Parâmetro obrigatório fornecido corretamente
        salaEdicao: salaEdicao,        // Passa a sala se for edição
      ),
    );

    if (atualizou == true) {
      await _carregarSalas();
    }
  }

  @override
  Widget build(BuildContext context) {
    final listaFiltrada = _salas.where((s) {
      final nome = s.nomeSala ?? ""; 
      return nome.toLowerCase().contains(_termoBusca.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("SALAS DE ATENDIMENTO"),
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
                hintText: "BUSCAR SALA POR NOME...",
                fillColor: Colors.white,
                filled: true,
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("NOVA SALA", style: TextStyle(color: Colors.white)),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : _erroAviso != null
              ? Center(child: Text(_erroAviso!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)))
              : listaFiltrada.isEmpty
                  ? const Center(child: Text("NENHUMA SALA CADASTRADA."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: listaFiltrada.length,
                      itemBuilder: (context, index) {
                        final sala = listaFiltrada[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.teal,
                              child: Icon(Icons.meeting_room, color: Colors.white),
                            ),
                            title: Text(sala.nomeSala ?? "SEM NOME", style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("TIPO: ${sala.tipo ?? 'N/D'}".toUpperCase()),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  tooltip: "EDITAR SALA",
                                  onPressed: () => _abrirFormulario(salaEdicao: sala),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  tooltip: "EXCLUIR SALA",
                                  onPressed: () async {
                                    final confirmar = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text("EXCLUIR SALA?"),
                                        content: const Text("TEM CERTEZA QUE DESEJA EXCLUIR ESSA SALA?"),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("CANCELAR")),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                            onPressed: () => Navigator.pop(ctx, true),
                                            child: const Text("EXCLUIR"),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirmar == true) {
                                      try {
                                        await widget.service.excluir(sala.id!);
                                        await _carregarSalas();
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('SALA REMOVIDA COM SUCESSO!'), backgroundColor: Colors.red),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('ERRO AO EXCLUIR: $e'.toUpperCase()), backgroundColor: Colors.red),
                                          );
                                        }
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
  }
}