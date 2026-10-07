import 'package:flutter/material.dart';
import '../../domain/services/ala_service.dart';
import '../../domain/entities/ala.dart';
import 'cadastrar_ala.dart';

class ListarAlas extends StatefulWidget {
  final AlaService service;
  const ListarAlas({super.key, required this.service});

  @override
  State<ListarAlas> createState() => _ListarAlasState();
}

class _ListarAlasState extends State<ListarAlas> {
  final TextEditingController _buscaCtrl = TextEditingController();
  String _termoBusca = '';

  List<Ala> _alas = [];
  bool _carregando = true;
  String? _erroAviso;

  @override
  void initState() {
    super.initState();
    _carregarAlas();
  }

  @override
  void dispose() {
    // Destrói o controller para liberar memória quando a tela é fechada
    _buscaCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregarAlas() async {
    if (!mounted) return;
    setState(() {
      _carregando = true;
      _erroAviso = null;
    });

    try {
      final alasDoBanco = await widget.service.listarAlas();
      if (mounted) {
        setState(() {
          _alas = alasDoBanco;
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _carregando = false;
          _erroAviso = e.toString();
        });
      }
    }
  }

  void _abrirFormulario({Ala? alaEdicao}) async {
    final atualizou = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CadastrarAla(
        service: widget.service,
        alaEdicao: alaEdicao,
      ),
    );

    if (atualizou == true) {
      await _carregarAlas();
    }
  }

  // Cor personalizada para cada tipo de ala
  Color _getTipoColor(String? tipo) {
    switch (tipo?.toUpperCase()) {
      case 'PREMIUM':
        return Colors.amber.shade800;
      case 'PRIVADO':
        return Colors.blue.shade700;
      case 'COMUM':
      default:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filtro de pesquisa visual
    final listaFiltrada = _alas.where((a) {
      return a.nomeAla
          .toLowerCase()
          .trim()
          .contains(_termoBusca.toLowerCase().trim());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gerenciar Alas Hospitalares"),
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
                hintText: "Buscar ala por nome...",
                fillColor: Colors.white,
                filled: true,
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      // Botão Novo
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Nova Ala", style: TextStyle(color: Colors.white)),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : _erroAviso != null
              ? Center(
                  child: Text(
                    "⚠️ ERRO:\n\n$_erroAviso",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : listaFiltrada.isEmpty
                  ? const Center(
                      child: Text("Nenhuma ala cadastrada ou encontrada."),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: listaFiltrada.length,
                      itemBuilder: (context, i) {
                        final ala = listaFiltrada[i];
                        final tipoText = ala.tipo ?? 'COMUM';

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.teal.shade50,
                              child: const Icon(Icons.domain, color: Colors.teal),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    ala.nomeAla,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Tag visual com o Tipo de Ala
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getTipoColor(tipoText)
                                        .withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _getTipoColor(tipoText),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    tipoText,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: _getTipoColor(tipoText),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text("Localização: ${ala.andar}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  tooltip: "Editar Ala",
                                  onPressed: () =>
                                      _abrirFormulario(alaEdicao: ala),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  tooltip: "Excluir Ala",
                                  onPressed: () async {
                                    final confirmar = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text("Excluir Ala?"),
                                        content: const Text(
                                          "Tem certeza? Alas com leitos vinculados não podem ser excluídas.",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text("Cancelar"),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: const Text("Excluir"),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirmar == true) {
                                      try {
                                        await widget.service
                                            .deletarAla(ala.id!);
                                        await _carregarAlas();
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text('Ala removida.'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text('$e'),
                                              backgroundColor: Colors.red,
                                            ),
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