// lib/pages/dashboard.dart
import 'package:flutter/material.dart';
import 'package:gestaohospitalar01/domain/entities/paciente.dart';
import 'package:gestaohospitalar01/domain/services/triagem_service.dart';
import 'package:sqflite/sqflite.dart';

// PACIENTES
import 'pacientes/listar_paciente.dart';
import 'pacientes/cadastrar_paciente.dart';
// MEDICOS
import 'medicos/listar_medico.dart';
import 'medicos/cadastrar_medico.dart';
// CONVENIO
import 'convenios/listar_convenio.dart';
import 'convenios/cadastrar_convenio.dart';
// TRIAGEM
import 'triagem/realizar_triagem.dart';
// ATENDIMENTO
import 'atendimento/registrar_internacao.dart';

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

  List<Map<String, dynamic>> _filaTriagem = [];

  @override
  void initState() {
    // super.initState();
    // _pacienteService = PacienteService(widget.database);
    // _pacienteService.carregarPacientes();

    // _medicoService = MedicoService(widget.database);
    // _medicoService.carregarMedicos();

    // _convenioService = ConvenioService(widget.database);
    // _convenioService.carregarConvenios();

    // _triagemService = TriagemService(widget.database);
    // _carregarFila();

    super.initState();
    _pacienteService = PacienteService(widget.database);
    _medicoService = MedicoService(widget.database);
    _convenioService = ConvenioService(widget.database);
    _triagemService = TriagemService(widget.database);
    
    _carregarDadosIniciais();
  }

  Future<void> _carregarFila() async {
    final dados = await _triagemService.buscarFilaTriagem();
    setState(() {
      _filaTriagem = dados;
    });
  }

  // Carrega tudo que precisa ao abrir
  Future<void> _carregarDadosIniciais() async {
    await _pacienteService.carregarPacientes();
    await _carregarFila(); // Carrega a triagem
  }


  void _mostrarTriagem(String nivel, String titulo) {
    // Filtra a fila pela cor selecionada
    final lista = _filaTriagem.where((t) => t['risco'] == nivel).toList();

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
              final item = lista[i];
              // Busca o objeto Paciente original para abrir o prontuário
              final p = _pacienteService.pacientes.firstWhere((pac) => pac.id == item['id_paciente']);
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text("${i + 1}")),
                  title: Text(item['nome'] ?? 'Sem Nome'),
                  onTap: () {
                    Navigator.pop(context);
                    _abrirProntuarioMedico(p);
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
      context: context,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            Text("Prontuário: ${p.nome}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Divider(),
            Text("CPF: ${p.cpf}"),
            const SizedBox(height: 20),
            if (triagem != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text("Queixa: ${triagem.queixa}"),
                      Text("Sinais: PA ${triagem.pressao} | Temp ${triagem.temperatura}°C"),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Expanded(
              child: TextFormField(
                controller: condutaCtrl,
                maxLines: 6,
                decoration: const InputDecoration(labelText: "Conduta Médica / Evolução", border: OutlineInputBorder()),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () async {
                      if (triagem != null) {
                        final triagemAtualizada = triagem.copyWith(observacoes: condutaCtrl.text, internacao: 'NAO');
                        await _triagemService.salvarTriagem(triagemAtualizada);
                        await _pacienteService.arquivarPaciente(p);
                        if (mounted) {
                          Navigator.pop(context);
                          _carregarFila(); // Atualiza a fila
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Alta concedida!")));
                        }
                      }
                    },
                    child: const Text("Dar Alta", style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    onPressed: () async {
                      if (triagem != null) {
                        final triagemAtualizada = triagem.copyWith(observacoes: condutaCtrl.text, internacao: 'SIM');
                        await _triagemService.salvarTriagem(triagemAtualizada);
                        if (mounted) {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegistrarInternacao(paciente: p, pacienteService: _pacienteService),
                            ),
                          );
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
      appBar: AppBar(title: const Text("MONGE - GESTÃO HOSPITALAR"), backgroundColor: Colors.teal, foregroundColor: Colors.white),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) {
              setState(() => _selectedIndex = i);
            },
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text("Início")),
              NavigationRailDestination(icon: Icon(Icons.local_pharmacy), label: Text("Farmácia")),
              NavigationRailDestination(icon: Icon(Icons.people), label: Text("Pacientes")),
              NavigationRailDestination(icon: Icon(Icons.medical_services), label: Text("Médicos")),
              NavigationRailDestination(icon: Icon(Icons.bed), label: Text("Leitos")),
              NavigationRailDestination(icon: Icon(Icons.inventory), label: Text("Estoque")),
              NavigationRailDestination(icon: Icon(Icons.attach_money), label: Text("Faturamento")),
              NavigationRailDestination(icon: Icon(Icons.healing), label: Text("Atendimento")),
              NavigationRailDestination(icon: Icon(Icons.business), label: Text("Convênios")),
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
      case 2: return ListarPaciente(service: _pacienteService, convenioService: _convenioService);
      case 3: return ListarMedico(service: _medicoService);
      case 4: return const TelaMapaLeitos();
      default: return _dashboard();
    }
  }

  Widget _dashboard() {
    // Calcula as contagens baseadas na FILA DE TRIAGEM real
    int emergencia = _filaTriagem.where((t) => t['risco'] == "VERMELHO").length;
    int muitoUrgente = _filaTriagem.where((t) => t['risco'] == "LARANJA").length;
    int urgente = _filaTriagem.where((t) => t['risco'] == "AMARELO").length;
    int poucoUrgente = _filaTriagem.where((t) => t['risco'] == "VERDE").length;
    int naoUrgente = _filaTriagem.where((t) => t['risco'] == "AZUL").length;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Painel Geral (Triagem Ativa)", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            children: [
              GestureDetector(onTap: () => _mostrarTriagem("VERMELHO", "Emergência"), child: _card("🔴 Emergência", emergencia, Colors.red)),
              GestureDetector(onTap: () => _mostrarTriagem("LARANJA", "Muito Urgente"), child: _card("🟠 Muito Urgente", muitoUrgente, Colors.orange)),
              GestureDetector(onTap: () => _mostrarTriagem("AMARELO", "Urgente"), child: _card("🟡 Urgente", urgente, Colors.yellow.shade700)),
              GestureDetector(onTap: () => _mostrarTriagem("VERDE", "Pouco Urgente"), child: _card("🟢 Pouco Urgente", poucoUrgente, Colors.green)),
              GestureDetector(onTap: () => _mostrarTriagem("AZUL", "Não Urgente"), child: _card("🔵 Não Urgente", naoUrgente, Colors.blue)),
            ],
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () async {
               // Quando fechar o cadastro de triagem, recarrega a fila
              await Navigator.push(context, MaterialPageRoute(builder: (_) => RealizarTriagem(pacienteService: _pacienteService, triagemService: _triagemService)));
              _carregarFila();
            },
            icon: const Icon(Icons.favorite),
            label: const Text("Nova Triagem"),
          ),
        ],
      ),
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