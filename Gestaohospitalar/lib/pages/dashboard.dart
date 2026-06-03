// lib/pages/dashboard.dart
import 'package:flutter/material.dart';
import 'package:gestaohospitalar01/domain/entities/paciente.dart';
import 'package:gestaohospitalar01/domain/services/triagem_service.dart';
import 'package:sqflite/sqflite.dart';

import 'pacientes/listar_paciente.dart'; 
import 'pacientes/cadastrar_paciente.dart';

// Imports do módulo de Médicos
import 'medicos/listar_medico.dart';
import 'medicos/cadastrar_medico.dart';

// ✅ Imports corrigidos e vinculados do módulo de Convênios
import 'convenios/listar_convenio.dart';
import 'convenios/cadastrar_convenio.dart';

//Imports da triagem
import 'triagem/realizar_triagem.dart'; // A pasta que você acabou de criar

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

  late TriagemService _triagemService;
  @override
  void initState() {
    super.initState();
    _pacienteService = PacienteService(widget.database);
    _pacienteService.carregarPacientes();

    _medicoService = MedicoService(widget.database);
    _medicoService.carregarMedicos();

    _convenioService = ConvenioService(widget.database);
    _convenioService.carregarConvenios();

    _triagemService = TriagemService(widget.database); // ✅ Inicializa o serviço de triagem
  }

  void _mostrarTriagem(String nivel, String titulo) {
    // Ordenado por ID (quem entrou primeiro na fila)
    final lista = _pacienteService.pacientes
        .where((p) => p.historicoClinico == nivel)
        .toList()..sort((a, b) => a.id!.compareTo(b.id!));

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Fila: $titulo"),
        content: SizedBox(
          width: 400,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: lista.length,
            itemBuilder: (context, i) {
              final p = lista[i];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text("${i + 1}")), // Numeração da fila
                  title: Text(p.nome ?? 'Sem Nome'),
                  onTap: () {
                    Navigator.pop(context); // Fecha a lista
                    _abrirProntuarioMedico(p); // Abre a ficha completa
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _abrirProntuarioMedico(Paciente p) async {
    final triagem = await _triagemService.buscarTriagemPorPaciente(p.id!);
    final condutaCtrl = TextEditingController(text: triagem?.observacoes ?? '');

    if (!mounted) return;

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            Text("Prontuário: ${p.nome}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Divider(),
            // Exibição dos dados do Paciente
            Text("CPF: ${p.cpf} | Nascimento: ${p.nascimento?.day}/${p.nascimento?.month}/${p.nascimento?.year}"),
            const SizedBox(height: 10),
            // Exibição da Triagem
            if (triagem != null) Card(
              child: Padding(padding: const EdgeInsets.all(12), child: Column(
                children: [
                  Text("Queixa: ${triagem.queixa}"),
                  Text("Sinais: PA ${triagem.pressao} | Temp ${triagem.temperatura}°C | Sat ${triagem.saturacao}%"),
                ],
              )),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TextFormField(
                controller: condutaCtrl, maxLines: 6,
                decoration: const InputDecoration(labelText: "Conduta Médica / Evolução", border: OutlineInputBorder()),
              ),
            ),
           // Botões de decisão final
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () async {
                      if (triagem != null) {
                        // ✅ CRIA UMA CÓPIA ATUALIZADA (Sem erro de setter)
                        final triagemAtualizada = triagem.copyWith(
                          observacoes: condutaCtrl.text,
                          internacao: 'NAO'
                        );
                        
                        await _triagemService.salvarTriagem(triagemAtualizada);
                        await _pacienteService.arquivarPaciente(p);
                        
                        if (mounted) {
                          Navigator.pop(context); // Fecha o modal
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Alta concedida com sucesso!")));
                        }
                      }
                    },
                    child: const Text("Dar Alta", style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    onPressed: () async {
                      if (triagem != null) {
                        // ✅ CRIA UMA CÓPIA ATUALIZADA (Sem erro de setter)
                        final triagemAtualizada = triagem.copyWith(
                          observacoes: condutaCtrl.text,
                          internacao: 'SIM'
                        );
                        
                        await _triagemService.salvarTriagem(triagemAtualizada);
                        
                        if (mounted) {
                          Navigator.pop(context); // Fecha o modal
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Paciente encaminhado para internação.")));
                        }
                      }
                    },
                    child: const Text("Internar", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            )
          ],
        ),
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
      case 2: return ListarPaciente(service: _pacienteService, convenioService: _convenioService); // 👈 Atualize esta linha
      case 3: return ListarMedico(service: _medicoService); 
      case 4: return const TelaMapaLeitos();
      case 5: return const TelaEstoque();
      case 6: return const TelaFaturamento();
      case 7: return TelaAtendimentoMedico(database: widget.database);
      case 8: return ListarConvenio(service: _convenioService); // ✅ Mapeamento da listagem na aba lateral!
      default: return _dashboard();
    }
  }

  Widget _dashboard() {
    return ListenableBuilder(
      listenable: _pacienteService,
      builder: (context, _) {
        int emergencia = _pacienteService.pacientes.where((p) => p.historicoClinico == "Emergência").length;
        int muitoUrgente = _pacienteService.pacientes.where((p) => p.historicoClinico == "Muito Urgente").length;
        int urgente = _pacienteService.pacientes.where((p) => p.historicoClinico == "Urgente").length;
        int poucoUrgente = _pacienteService.pacientes.where((p) => p.historicoClinico == "Pouco Urgente").length;
        int naoUrgente = _pacienteService.pacientes.where((p) => p.historicoClinico == "Não Urgente").length;

        // Função auxiliar para simplificar a chamada do diálogo lateral
        void abrirDialogoLateral(Widget content) {
          showGeneralDialog(
            context: context,
            barrierDismissible: true,
            barrierLabel: "Cadastro",
            barrierColor: Colors.black54,
            transitionDuration: const Duration(milliseconds: 300),
            transitionBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(animation),
                child: child,
              );
            },
            pageBuilder: (context, animation, secondaryAnimation) {
              return Align(
                alignment: Alignment.centerRight,
                child: Material(
                  elevation: 10,
                  color: Colors.white,
                  child: Container(
                    width: 550,
                    height: double.infinity,
                    child: content,
                  ),
                ),
              );
            },
          );
        }

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
                  GestureDetector(onTap: () => _mostrarTriagem("Emergência", "Emergência"), child: _card("🔴 Emergência", emergencia, Colors.red)),
                  GestureDetector(onTap: () => _mostrarTriagem("Muito Urgente", "Muito Urgente"), child: _card("🟠 Muito Urgente", muitoUrgente, Colors.orange)),
                  GestureDetector(onTap: () => _mostrarTriagem("Urgente", "Urgente"), child: _card("🟡 Urgente", urgente, Colors.yellow[700]!)),
                  GestureDetector(onTap: () => _mostrarTriagem("Pouco Urgente", "Pouco Urgente"), child: _card("🟢 Pouco Urgente", poucoUrgente, Colors.green)),
                  GestureDetector(onTap: () => _mostrarTriagem("Não Urgente", "Não Urgente"), child: _card("🔵 Não Urgente", naoUrgente, Colors.blue)),
                ],
              ),
              const SizedBox(height: 30),
              Wrap(
                spacing: 12,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => abrirDialogoLateral(CadastrarPaciente(service: _pacienteService, convenioService: _convenioService)),
                    icon: const Icon(Icons.person_add),
                    label: const Text("Paciente"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => abrirDialogoLateral(CadastrarMedico(service: _medicoService)),
                    icon: const Icon(Icons.medical_services),
                    label: const Text("Médico"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => abrirDialogoLateral(CadastrarConvenio(service: _convenioService)),
                    icon: const Icon(Icons.business),
                    label: const Text("Convênio"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => abrirDialogoLateral(RealizarTriagem(pacienteService: _pacienteService, triagemService: _triagemService)),
                    icon: const Icon(Icons.favorite),
                    label: const Text("Triagem"),
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