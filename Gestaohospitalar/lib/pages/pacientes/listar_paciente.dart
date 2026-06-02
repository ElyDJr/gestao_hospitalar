// lib/pages/paciente/listar_paciente.dart
import 'package:flutter/material.dart';
import '../../../domain/services/paciente_service.dart';
import 'cadastrar_paciente.dart';

class ListarPaciente extends StatefulWidget {
  final PacienteService service;

  const ListarPaciente({super.key, required this.service});

  @override
  State<ListarPaciente> createState() => _ListarPacienteState();
}

class _ListarPacienteState extends State<ListarPaciente> {
  final TextEditingController _buscaCtrl = TextEditingController();
  String _termoBusca = '';

  @override
  void initState() {
    super.initState();
    widget.service.carregarPacientes();
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.service,
      builder: (context, _) {
        if (widget.service.isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.teal)));

        final listaFiltrada = widget.service.pacientes.where((p) {
          final nome = p.nome?.toLowerCase() ?? '';
          final cpf = p.cpf ?? '';
          return nome.contains(_termoBusca.toLowerCase()) || cpf.contains(_termoBusca.toLowerCase());
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text("Central de Pacientes"),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  controller: _buscaCtrl,
                  onChanged: (v) => setState(() => _termoBusca = v),
                  decoration: InputDecoration(
                    hintText: "Buscar paciente por nome ou CPF...",
                    fillColor: Colors.white, filled: true,
                    prefixIcon: const Icon(Icons.search, color: Colors.teal),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => CadastrarPaciente(service: widget.service));
            },
            backgroundColor: Colors.teal,
            icon: const Icon(Icons.person_add, color: Colors.white),
            label: const Text("Registrar Paciente", style: TextStyle(color: Colors.white)),
          ),
          body: listaFiltrada.isEmpty
              ? const Center(child: Text("Nenhum paciente ativo encontrado.", style: TextStyle(fontSize: 16, color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: listaFiltrada.length,
                  itemBuilder: (context, i) {
                    final p = listaFiltrada[i];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.person, color: Colors.white)),
                        title: Text(p.nome ?? 'Sem Nome', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("CPF: ${p.cpf} | Cidade: ${p.cidade ?? 'Não Informada'}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (p.tipoSanguineo != null)
                              Chip(label: Text(p.tipoSanguineo!), backgroundColor: Colors.red.withValues(alpha: 0.1), labelStyle: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            
                            // ✅ BOTÃO EDITAR (LÁPIS)
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              tooltip: "Editar Paciente",
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                                  builder: (context) => CadastrarPaciente(service: widget.service, pacienteEdicao: p), // Passa os dados!
                                );
                              },
                            ),

                            // ✅ BOTÃO ARQUIVAR (SOFT DELETE)
                            IconButton(
                              icon: const Icon(Icons.archive_outlined, color: Colors.orange),
                              tooltip: "Arquivar Paciente",
                              onPressed: () async {
                                final confirmar = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Arquivar Paciente?"),
                                    content: Text("O paciente ${p.nome} sairá desta lista, mas o histórico continuará salvo no banco de dados."),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text("Arquivar"),
                                      ),
                                    ],
                                  )
                                );
                                if (confirmar == true) {
                                  await widget.service.arquivarPaciente(p);
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