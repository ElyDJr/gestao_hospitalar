// lib/pages/pacientes/listar_paciente.dart
import 'package:flutter/material.dart';
import '../../../domain/services/paciente_service.dart';
import '../../../domain/entities/paciente.dart';
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
    _buscaCtrl.dispose(); // ✅ Uso correto e liberação de memória do controller
    super.dispose();
  }

  void _abrirFormularioCadastro({Paciente? pacienteParaEditar}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CadastrarPaciente(
        service: widget.service,
        pacienteEdicao: pacienteParaEditar, // ✅ Totalmente alinhado com o seu formulário restaurado
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.service,
      builder: (context, _) {
        if (widget.service.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.teal)));
        }

        // 🔍 Lógica de filtragem reativa por Nome ou CPF
        final listaFiltrada = widget.service.pacientes.where((p) {
          final nome = p.nome?.toLowerCase() ?? '';
          final cpf = p.cpf ?? '';
          final busca = _termoBusca.toLowerCase();
          return nome.contains(busca) || cpf.contains(busca);
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
                  onChanged: (valor) {
                    setState(() {
                      _termoBusca = valor;
                    });
                  },
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: "Buscar paciente por nome ou CPF...",
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
            icon: const Icon(Icons.person_add, color: Colors.white),
            label: const Text("Registrar Paciente", style: TextStyle(color: Colors.white)),
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
                            ? "Nenhum prontuário ativo encontrado." 
                            : "Nenhum paciente encontrado para '$_termoBusca'.", 
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: listaFiltrada.length,
                  itemBuilder: (context, i) {
                    final p = listaFiltrada[i];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(p.nome ?? 'Sem Nome', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("CPF: ${p.cpf} | Cidade: ${p.cidade ?? 'Não Informada'}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (p.tipoSanguineo != null)
                              Chip(
                                label: Text(p.tipoSanguineo!),
                                backgroundColor: Colors.red.withValues(alpha: 0.1),
                                labelStyle: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              tooltip: "Editar Paciente",
                              onPressed: () => _abrirFormularioCadastro(pacienteParaEditar: p),
                            ),
                            IconButton(
                              icon: const Icon(Icons.archive_outlined, color: Colors.orange),
                              tooltip: "Arquivar Paciente",
                              onPressed: () async {
                                final confirmar = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Arquivar Paciente?"),
                                    content: Text("O paciente ${p.nome} sairá desta lista ativa, mantendo o histórico no banco."),
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
                                  await widget.service.arquivarPaciente(p);
                                  
                                  // ✅ MENSAGEM DE ARQUIVAMENTO AQUI
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Prontuário de ${p.nome} arquivado!'), backgroundColor: Colors.orange)
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