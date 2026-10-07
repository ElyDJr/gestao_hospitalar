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
              child: CircularProgressIndicator(),
            )
          : _medicos.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum médico cadastrado.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: _medicos.length,
                  itemBuilder: (context, index) {
                    final medico = _medicos[index];

                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.teal,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        medico.nome ?? 'Sem Nome',
                      ),
                      subtitle: Text(
                        'CRM: ${medico.crm ?? 'Não informado'}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.blue,
                        ),
                        onPressed: () async {
                          await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => CadastrarMedico(
                              service: widget.service,
                              medicoEdicao: medico,
                            ),
                          );

                          // Recarrega a lista depois de editar
                          _carregarMedicos();
                        },
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

          // Recarrega a lista depois de cadastrar
          _carregarMedicos();
        },
      ),
    );
  }
}