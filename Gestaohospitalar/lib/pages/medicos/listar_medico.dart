// lib/pages/medicos/listar_medico.dart
import 'package:flutter/material.dart';
import '../../../domain/entities/medico.dart';
import '../../../domain/services/medico_service.dart';
import 'cadastrar_medico.dart';

class ListarMedico extends StatefulWidget {
  final MedicoService service;

  const ListarMedico({
    super.key,
    required this.service,
  });

  @override
  State<ListarMedico> createState() => _ListarMedicoState();
}

class _ListarMedicoState extends State<ListarMedico> {
  List<Medico> _medicos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarMedicos();
  }

  Future<void> _carregarMedicos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final medicos = await widget.service.listarMedicos();

      if (mounted) {
        setState(() {
          _medicos = medicos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar médicos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Médicos'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.teal),
            )
          : _medicos.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum médico cadastrado.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _medicos.length,
                  itemBuilder: (context, index) {
                    final medico = _medicos[index];
                    final nomeMedico = medico.nome ?? 'Sem Nome';

                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.teal,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(nomeMedico),
                      subtitle: Text(
                        'CRM: ${medico.crm ?? 'Não informado'}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ✏️ Editar
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.blue,
                            ),
                            tooltip: 'Editar Médico',
                            onPressed: () async {
                              await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) => CadastrarMedico(
                                  service: widget.service,
                                  medicoEdicao: medico,
                                ),
                              );

                              _carregarMedicos();
                            },
                          ),

                          // 📦 Arquivar
                          IconButton(
                            icon: const Icon(
                              Icons.archive_outlined,
                              color: Colors.orange,
                            ),
                            tooltip: 'Arquivar Médico',
                            onPressed: () async {
                              final confirmar = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Arquivar Médico?"),
                                  content: Text(
                                    "O médico $nomeMedico sairá desta lista ativa e será movido para o arquivo.",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text("Cancelar"),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text("Arquivar"),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmar == true) {
                                try {
                                  await widget.service.arquivarMedico(medico);
                                  await _carregarMedicos();

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Médico $nomeMedico arquivado com sucesso!'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Erro ao arquivar: $e'),
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
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () async {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => CadastrarMedico(
              service: widget.service,
            ),
          );

          _carregarMedicos();
        },
      ),
    );
  }
}