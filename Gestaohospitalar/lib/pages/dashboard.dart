// lib/pages/dashboard.dart
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'pacientes/listar_paciente.dart'; 
import 'pacientes/cadastrar_paciente.dart';

// Imports do módulo de Médicos
import 'medicos/listar_medico.dart';
import 'medicos/cadastrar_medico.dart';

// ✅ Imports corrigidos e vinculados do módulo de Convênios
import 'convenios/listar_convenio.dart';
import 'convenios/cadastrar_convenio.dart';

import '../telas/tela_mapa_leitos.dart';
import '../telas/tela_estoque.dart';
import '../telas/tela_faturamento.dart';
import '../telas/tela_farmacia.dart';
import '../telas/tela_atendimento_medico.dart';

import '../domain/services/paciente_service.dart';
import '../domain/services/medico_service.dart'; 
import '../domain/services/convenio_service.dart';

class Dashboard extends StatefulWidget {
  final Database database;

  const Dashboard({super.key, required this.database});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;
  late PacienteService _pacienteService;
  late MedicoService _medicoService; 
  late ConvenioService _convenioService;

  @override
  void initState() {
    super.initState();
    _pacienteService = PacienteService(widget.database);
    _pacienteService.carregarPacientes();

    _medicoService = MedicoService(widget.database);
    _medicoService.carregarMedicos();

    _convenioService = ConvenioService(widget.database);
    _convenioService.carregarConvenios();
  }

  void _mostrarTriagem(String nivel, String titulo) {
    final lista = _pacienteService.pacientes.where((p) => p.historicoClinico == nivel).toList();
    showDialog(
      context: context,
      builder: (_) => ListenableBuilder(
        listenable: _pacienteService,
        builder: (context, _) {
          return AlertDialog(
            title: Text("Triagem - $titulo"),
            content: SizedBox(
              width: 420,
              child: lista.isEmpty
                  ? const Text("Nenhum paciente nesta classificação")
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: lista.length,
                      itemBuilder: (context, i) {
                        final p = lista[i];
                        return Card(
                          child: ListTile(
                            title: Text(p.nome ?? 'Sem Nome'),
                            subtitle: Text("CPF: ${p.cpf ?? 'Não informado'}"),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                              onPressed: () async {
                                // 1. Arquiva no banco
                                if (p.id != null) {
                                  await _pacienteService.arquivarPaciente(p);
                                }
                                
                                // 2. Fecha o dialog e mostra a mensagem
                                if (context.mounted) {
                                  Navigator.pop(context); // Fecha a telinha da triagem
                                  
                                  // ✅ A MENSAGEM VEM AQUI, DEPOIS DE FECHAR O DIALOG!
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Alta realizada! O prontuário de ${p.nome} foi arquivado.'),
                                      backgroundColor: Colors.green,
                                      duration: const Duration(seconds: 3), // Opcional: tempo da mensagem
                                    ),
                                  );
                                }
                              },
                              child: const Text("Dar Alta"), // O child continua intacto aqui
                            ),
                          ),
                        );
                      },
                    ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MONGE - GESTÃO HOSPITALAR"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) {
              setState(() => _selectedIndex = i);
              _pacienteService.carregarPacientes();
              _medicoService.carregarMedicos(); 
              _convenioService.carregarConvenios(); // ✅ Força recarga ao navegar
            },
            extended: false,
            labelType: NavigationRailLabelType.none,
            destinations: const [
              NavigationRailDestination(icon: Tooltip(message: "Início", child: Icon(Icons.dashboard)), label: Text("Início")),
              NavigationRailDestination(icon: Tooltip(message: "Farmácia", child: Icon(Icons.local_pharmacy)), label: Text("Farmácia")),
              NavigationRailDestination(icon: Tooltip(message: "Pacientes", child: Icon(Icons.people)), label: Text("Pacientes")),
              NavigationRailDestination(icon: Tooltip(message: "Médicos", child: Icon(Icons.medical_services)), label: Text("Médicos")), 
              NavigationRailDestination(icon: Tooltip(message: "Leitos", child: Icon(Icons.bed)), label: Text("Leitos")),
              NavigationRailDestination(icon: Tooltip(message: "Estoque", child: Icon(Icons.inventory)), label: Text("Estoque")),
              NavigationRailDestination(icon: Tooltip(message: "Faturamento", child: Icon(Icons.attach_money)), label: Text("Faturamento")),
              NavigationRailDestination(icon: Tooltip(message: "Atendimento", child: Icon(Icons.healing)), label: Text("Atendimento")),
              NavigationRailDestination(icon: Tooltip(message: "Convênios", child: Icon(Icons.business)), label: Text("Convênios")),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _getPage(_selectedIndex)),
        ],
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0: return _dashboard();
      case 1: return const TelaFarmacia();
      case 2: return ListarPaciente(service: _pacienteService);
      case 3: return ListarMedico(service: _medicoService); 
      case 4: return const TelaMapaLeitos();
      case 5: return const TelaEstoque();
      case 6: return const TelaFaturamento();
      case 7: return const TelaAtendimentoMedico();
      case 8: return ListarConvenio(service: _convenioService); // ✅ Mapeamento da listagem na aba lateral!
      default: return _dashboard();
    }
  }

  Widget _dashboard() {
    return ListenableBuilder(
      listenable: _pacienteService,
      builder: (context, _) {
        int emergencia = _pacienteService.pacientes.where((p) => p.historicoClinico == "Emergência").length;
        int urgencia = _pacienteService.pacientes.where((p) => p.historicoClinico == "Urgência").length;
        int poucoUrgente = _pacienteService.pacientes.where((p) => p.historicoClinico == "Pouco Urgente").length;
        int naoUrgente = _pacienteService.pacientes.where((p) => p.historicoClinico == "Não Urgente").length;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Painel Geral", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                children: [
                  GestureDetector(onTap: () => _mostrarTriagem("Emergência", "Emergência"), child: _card("Emergência", emergencia, Colors.red)),
                  GestureDetector(onTap: () => _mostrarTriagem("Urgência", "Urgência"), child: _card("Urgência", urgencia, Colors.orange)),
                  GestureDetector(onTap: () => _mostrarTriagem("Pouco Urgente", "Pouco Urgente"), child: _card("Pouco Urgente", poucoUrgente, Colors.yellow[700]!)),
                  GestureDetector(onTap: () => _mostrarTriagem("Não Urgente", "Não Urgente"), child: _card("Não Urgente", naoUrgente, Colors.green)),
                ],
              ),
              const SizedBox(height: 30),
              Wrap(
                spacing: 12,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => CadastrarPaciente(service: _pacienteService));
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text("Paciente"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => CadastrarMedico(service: _medicoService));
                    },
                    icon: const Icon(Icons.medical_services),
                    label: const Text("Médico"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // ✅ Atalho direto para inclusão rápida
                      showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => CadastrarConvenio(service: _convenioService));
                    },
                    icon: const Icon(Icons.business),
                    label: const Text("Convênio"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _card(String title, int value, Color color) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: color)),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text("$value", style: TextStyle(fontSize: 26, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}