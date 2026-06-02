// lib/pages/medicos/listar_medico.dart
import 'package:flutter/material.dart';
import '../../../domain/services/medico_service.dart';
import 'cadastrar_medico.dart';

class ListarMedico extends StatefulWidget {
  final MedicoService service;

  const ListarMedico({super.key, required this.service});

  @override
  State<ListarMedico> createState() => _ListarMedicoState();
}

class _ListarMedicoState extends State<ListarMedico> {
  final TextEditingController _buscaCtrl = TextEditingController();
  String _termoBusca = '';

  @override
  void initState() {
    super.initState();
    widget.service.carregarMedicos();
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  void _abrirFormularioCadastro() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CadastrarMedico(service: widget.service),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.service,
      builder: (context, _) {
        if (widget.service.isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.teal)));

        final listaFiltrada = widget.service.medicos.where((m) {
          final nome = m.nome?.toLowerCase() ?? '';
          final crm = m.crm?.toLowerCase() ?? '';
          final busca = _termoBusca.toLowerCase();
          return nome.contains(busca) || crm.contains(busca);
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text("Corpo Clínico"),
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
                    hintText: "Buscar médico por nome ou CRM...",
                    fillColor: Colors.white,
                    filled: true,
                    prefixIcon: const Icon(Icons.search, color: Colors.teal),
                    suffixIcon: _termoBusca.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, color: Colors.grey), onPressed: () { _buscaCtrl.clear(); setState(() => _termoBusca = ''); }) : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _abrirFormularioCadastro,
            backgroundColor: Colors.teal,
            icon: const Icon(Icons.person_add, color: Colors.white),
            label: const Text("Novo Médico", style: TextStyle(color: Colors.white)),
          ),
          body: listaFiltrada.isEmpty
              ? const Center(child: Text("Nenhum médico encontrado.", style: TextStyle(fontSize: 16, color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: listaFiltrada.length,
                  itemBuilder: (context, i) {
                    final m = listaFiltrada[i];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.medical_services, color: Colors.white)),
                        title: Text(m.nome ?? 'Sem Nome', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("CRM: ${m.crm} | Contato: ${m.telefone ?? 'Não informado'}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () async {
                            if (m.id != null) await widget.service.deletarMedico(m.id!);
                          },
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