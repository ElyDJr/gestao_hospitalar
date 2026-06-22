// import 'package:flutter/material.dart';
// import '../../../domain/services/sala_service.dart';
// import '../../../domain/entities/sala.dart';
// import 'cadastrar_salas.dart';

// class ListarSalas extends StatefulWidget {
//   final SalaService service;
//   const ListarSalas({super.key, required this.service});

//   @override
//   State<ListarSalas> createState() => _ListarSalasState();
// }

// class _ListarSalasState extends State<ListarSalas> {
//   //final SalaService _salaService = SalaService();
//   final TextEditingController _buscaCtrl = TextEditingController();
//   String _termoBusca = '';

//   List<Sala> _salas = [];
//   bool _carregando = true;
//   String? _erroAviso;

//   @override
//   void initState() {
//     super.initState();
//     _carregarSalas();
//   }

//   Future<void> _carregarSalas() async {
//     // O service já retorna List<Sala>, não é preciso converter Maps aqui
//     if (!mounted) return;
//     setState(() { _carregando = true; _erroAviso = null; });

//     final lista = await widget.service.listarTodas();
    
//     if (mounted) {
//       setState(() {
//         _salas = lista;
//         _carregando = false;
//       });
//     }
//   }

//   void _abrirFormulario() async { //função async: espera a resposta do formulario
//     final atualizou = await showModalBottomSheet<bool>( //se o salvar ala receber true, atrualiza a lista
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => CadastrarSalas(
//         salaService: SalaService(),
//       ),
//     );
//     if (atualizou == true) {
//       await _carregarSalas(); // Pede ao service para buscar as alas novas
//       if (mounted) {
//         setState(() {}); // Força a tela a ser desenhada novamente com a lista atual
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Filtro de pesquisa visual
//     final listaFiltrada = _salas.where((s) {
//       return s.nomeSala.toLowerCase().trim().contains(_termoBusca.toLowerCase().trim());
//     }).toList();

//     return Scaffold(
//       appBar: AppBar(title: const Text("Salas de Atendimento"),
//       backgroundColor: Colors.teal,
//       foregroundColor: Colors.white,
//       bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(70),
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
//             child: TextField(
//               controller: _buscaCtrl,
//               onChanged: (valor) => setState(() => _termoBusca = valor),
//               decoration: InputDecoration(
//                 hintText: "Buscar ala por nome...",
//                 fillColor: Colors.white,
//                 filled: true,
//                 prefixIcon: const Icon(Icons.search, color: Colors.teal),
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
//               ),
//             ),
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () => _abrirFormulario(), // Chama a criação
//         backgroundColor: Colors.teal,
//         icon: const Icon(Icons.add, color: Colors.white),
//         label: const Text("Nova Ala", style: TextStyle(color: Colors.white)),
//       ),
//       body: _carregando
//           ? const Center(child: CircularProgressIndicator(color: Colors.teal))
//           : _erroAviso != null
//               // 🟢 MOSTRA NA TELA O MOTIVO REAL DE ESTAR VAZIO!
//               ? Center(child: Text("⚠️ ERRO:\n\n$_erroAviso", textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)))
//               : listaFiltrada.isEmpty
//           //: listaFiltrada.isEmpty
//               ? const Center(child: Text("Nenhuma ala cadastrada ou encontrada."))
//               : ListView.builder(
//                   padding: const EdgeInsets.all(20),
//                   itemCount: listaFiltrada.length,
//                   itemBuilder: (context, i) {
//                     final sala = listaFiltrada[i];
//                     return Card(
//                       elevation: 2,
//                       margin: const EdgeInsets.symmetric(vertical: 6),
//                       child: ListTile(
//                         leading: const CircleAvatar(
//                           backgroundColor: Colors.teal,
//                           child: Icon(Icons.domain, color: Colors.white),
//                         ),
//                         title: Text(sala.nomeSala, style: const TextStyle(fontWeight: FontWeight.bold)),
//                         trailing: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             IconButton(icon: const Icon(Icons.edit, color: Colors.blue), tooltip: "Editar Sala", onPressed: () => _abrirFormulario(salaEdicao: sala)),
//                             IconButton(
//                               icon: const Icon(Icons.delete, color: Colors.red),
//                               tooltip: "Excluir Sala",
//                               onPressed: () async {
//                                 final confirmar = await showDialog<bool>(
//                                   context: context,
//                                   builder: (ctx) => AlertDialog(
//                                     title: const Text("Excluir Sala?"),
//                                     content: const Text("Tem certeza que deseja excluir essa sala?"),
//                                     actions: [
//                                       TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancelar")),
//                                       ElevatedButton(
//                                         style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
//                                         onPressed: () => Navigator.pop(ctx, true),
//                                         child: const Text("Excluir"),
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                                 // Se confirmou a exclusão, deleta e atualiza a lista!
//                                 if (confirmar == true) {
//                                   try {
//                                     await widget.service.excluir(ala.id!);
//                                     await _carregarSalas(); // 🟢 Atualiza a lista pós-exclusão
//                                     if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sala removida.'), backgroundColor: Colors.red));
//                                   } catch (e) {
//                                     if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.red));
//                                   }
//                                 }
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../../../domain/services/sala_service.dart';
import '../../../domain/entities/sala.dart';
import 'cadastrar_salas.dart';

class ListarSalas extends StatefulWidget {
  final SalaService service;
  const ListarSalas({super.key, required this.service});

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
      // Busca a lista atualizada através do serviço injetado
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
          _erroAviso = "Erro ao carregar salas: ${e.toString()}";
        });
      }
    }
  }

  // Corrigido para receber o objeto Sala opcionalmente (para edição)
  void _abrirFormulario() async {
    final atualizou = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CadastrarSalas(
        salaService: widget.service, // Usa a mesma instância de serviço
        //salaEdicao: salaEdicao,      // Passa a sala se for edição
      ),
    );

    if (atualizou == true) {
      await _carregarSalas();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filtro de pesquisa
    final listaFiltrada = _salas.where((s) {
      final nome = s.nomeSala ?? ""; // Certifique-se de que o atributo na entidade é nomeSala
      return nome.toLowerCase().contains(_termoBusca.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Salas de Atendimento"),
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
                hintText: "Buscar sala por nome...",
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
        label: const Text("Nova Sala", style: TextStyle(color: Colors.white)),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : _erroAviso != null
              ? Center(child: Text(_erroAviso!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)))
              : listaFiltrada.isEmpty
                  ? const Center(child: Text("Nenhuma sala cadastrada."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: listaFiltrada.length,
                      itemBuilder: (context, index) {
                        final sala = _salas[index];
                        return ListTile(
                          title: Text(sala.nomeSala ?? "Sem nome"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => CadastrarSalas(salaService: widget.service, salaEdicao: sala)),
                                  );
                                  if (result == true) _carregarSalas();
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await widget.service.excluir(sala.id!);
                                  _carregarSalas();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}