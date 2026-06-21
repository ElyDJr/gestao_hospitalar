// lib/pages/dashboard.dart
import 'package:flutter/material.dart';
import 'package:gestaohospitalar01/domain/services/triagem_service.dart';
import 'package:sqflite/sqflite.dart';

// PACIENTES
import 'pacientes/listar_paciente.dart';
import 'pacientes/cadastrar_paciente.dart';

// MEDICOS
import 'medicos/listar_medico.dart';
import 'medicos/cadastrar_medico.dart';
import 'medicos/agenda_medica.dart';

// CONVENIO
import 'convenios/listar_convenio.dart';
import 'convenios/cadastrar_convenio.dart';

// EXAMES
import 'exames/cadastrar_exame.dart';
import 'exames/listar_exame.dart'; 

// ALMOXARIFADO / FARMÁCIA
import 'almoxarifado/listar_almoxarifado.dart';
import 'almoxarifado/cadastrar_almoxarifado.dart';
import '../domain/services/almoxarifado_service.dart';

// TRIAGEM
import 'triagem/realizar_triagem.dart';

// ATENDIMENTO
import 'atendimento/encaminhamento_form.dart';

// DASHBOARD
import 'login/tela_login.dart';

// LEITOS
import 'leitos/mapa_leitos.dart';
import 'leitos/cadastrar_leito.dart';
import '../domain/services/leito_service.dart';
import '../domain/services/exame_service.dart';

//ALAS
import '../domain/services/ala_service.dart';
import 'alas/listar_ala.dart';

import '../telas/tela_faturamento.dart';
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
  late LeitoService _leitoService;
  late ExameService _exameService;
  late AlmoxarifadoService _almoxarifadoService;
  late AlaService _alaService;

  List<Map<String, dynamic>> _filaTriagem = [];

  @override
  void initState() {
    super.initState();
    _pacienteService = PacienteService(widget.database);
    _pacienteService.carregarPacientes();

    _medicoService = MedicoService(widget.database);
    _medicoService.carregarMedicos();

    _convenioService = ConvenioService(widget.database);
    _convenioService.carregarConvenios();

    _triagemService = TriagemService(widget.database);
    _leitoService = LeitoService();
    
    _exameService = ExameService();
    _exameService.carregarExames();

    _almoxarifadoService = AlmoxarifadoService(widget.database);

    _alaService = AlaService();
    //_alaService.carregarAlas();


    
    _almoxarifadoService.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    });

    _almoxarifadoService.carregarItens();
    _carregarFila();
    _carregarDadosIniciais();
  }

  @override
  void dispose() {
    _almoxarifadoService.dispose();
    super.dispose();

    /*void dispose()
    O dispose limpa a memória quando a tela é fechada. */
  }

  Future<void> _carregarFila() async {
    final dados = await _triagemService.buscarFilaTriagem();
    setState(() {
      _filaTriagem = dados;
    });
  }

  Future<void> _carregarDadosIniciais() async {
    await _pacienteService.carregarPacientes();
    await _carregarFila();
  }

  void _mostrarTriagem(String nivel, String titulo) {
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
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text("${i + 1}")),
                  title: Text(item['nome'] ?? 'Sem Nome'),
                  onTap: () async {
                    Navigator.pop(context);
                    final p = _pacienteService.pacientes
                        .firstWhere((pac) => pac.id == item['id_paciente']);

                    await showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: SizedBox(
                          width: 650,
                          height: 800,
                          child: EncaminhamentoForm(
                            paciente: p,
                            triagem: item,
                            database: widget.database,
                          ),
                        ),
                      ),
                    );
                    _carregarFila();
                  },
                ),
              );
            },
          ),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair do Sistema',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => TelaLogin(database: widget.database)),
                (route) => false,
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) {
              setState(() => _selectedIndex = i);
            },
            destinations: [
              const NavigationRailDestination(icon: Tooltip(message: 'Início', child: Icon(Icons.dashboard)), label: Text("Início")),
              // VOLTOU PARA A ORDEM ORIGINAL (Índice 1) com o alerta
              NavigationRailDestination(
                icon: Badge(
                  isLabelVisible: _almoxarifadoService.temAlertaEstoque, 
                  label: const Icon(Icons.warning_amber_rounded, size: 12, color: Colors.white), 
                  backgroundColor: Colors.red, 
                  alignment: Alignment.topRight,
                  child: const Tooltip(message: 'Almoxarifado', child: Icon(Icons.inventory)),
                ),
                label: const Text("Almoxarifado"),
              ),
              const NavigationRailDestination(icon: Tooltip(message: 'Pacientes', child: Icon(Icons.people)), label: Text("Pacientes")),
              const NavigationRailDestination(icon: Tooltip(message: 'Médicos', child: Icon(Icons.medical_services)), label: Text("Médicos")),
              const NavigationRailDestination(icon: Tooltip(message: 'Leitos', child: Icon(Icons.bed)), label: Text("Leitos")),
              const NavigationRailDestination(icon: Tooltip(message: 'Agenda', child: Icon(Icons.calendar_month)), label: Text('Agenda')),
              const NavigationRailDestination(icon: Tooltip(message: 'Faturamento', child: Icon(Icons.attach_money)), label: Text("Faturamento")),
              const NavigationRailDestination(icon: Tooltip(message: 'Atendimento', child: Icon(Icons.healing)), label: Text("Atendimento")),
              const NavigationRailDestination(icon: Tooltip(message: 'Convênios', child: Icon(Icons.business)), label: Text("Convênios")),
              const NavigationRailDestination(icon: Tooltip(message: 'Exames', child: Icon(Icons.science)), label: Text("Exames")),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _getPage(_selectedIndex)),
        ],
      ),
    );
  }

  Widget _getPage(int index) {
    // VOLTOU PARA A ORDEM ORIGINAL
    switch (index) {
      case 0: return _dashboard();
      case 1: return ListarAlmoxarifado(service: _almoxarifadoService); 
      case 2: return ListarPaciente(service: _pacienteService, convenioService: _convenioService);
      case 3: return ListarMedico(service: _medicoService);
      case 4: return const MapaLeitos();
      case 5: return const AgendaMedicaTela();
      case 6: return const TelaFaturamento();
      case 7: return TelaAtendimentoMedico(database: widget.database);
      case 8: return ListarConvenio(service: _convenioService);
      case 9: return ListarExame(service: _exameService);
      default: return _dashboard();
    }
  }

  Widget _dashboard() {
    int emergencia = _filaTriagem.where((t) => t['risco'] == "VERMELHO").length;
    int muitoUrgente = _filaTriagem.where((t) => t['risco'] == "LARANJA").length;
    int urgente = _filaTriagem.where((t) => t['risco'] == "AMARELO").length;
    int poucoUrgente = _filaTriagem.where((t) => t['risco'] == "VERDE").length;
    int naoUrgente = _filaTriagem.where((t) => t['risco'] == "AZUL").length;

    Future<void> abrirDialogoLateral(Widget content) async {
      await showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: "Fechar Cadastro",
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 300),
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(animation),
            child: child,
          );
        },
        pageBuilder: (context, animation, secondaryAnimation) {
          return Align(
            alignment: Alignment.centerRight,
            child: Material(
              elevation: 10,
              color: Colors.white,
              child: SizedBox(
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
              GestureDetector(onTap: () => _mostrarTriagem("VERMELHO", "Emergência"), child: _card("🔴 Emergência", emergencia, Colors.red)),
              GestureDetector(onTap: () => _mostrarTriagem("LARANJA", "Muito Urgente"), child: _card("🟠 Muito Urgente", muitoUrgente, Colors.orange)),
              GestureDetector(onTap: () => _mostrarTriagem("AMARELO", "Urgente"), child: _card("🟡 Urgente", urgente, Colors.yellow.shade700)),
              GestureDetector(onTap: () => _mostrarTriagem("VERDE", "Pouco Urgente"), child: _card("🟢 Pouco Urgente", poucoUrgente, Colors.green)),
              GestureDetector(onTap: () => _mostrarTriagem("AZUL", "Não Urgente"), child: _card("🔵 Não Urgente", naoUrgente, Colors.blue)),
            ],
          ),
          const SizedBox(height: 30),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(onPressed: () async { await abrirDialogoLateral(CadastrarPaciente(service: _pacienteService, convenioService: _convenioService)); _pacienteService.carregarPacientes(); }, icon: const Icon(Icons.people), label: const Text("Paciente")),
              ElevatedButton.icon(onPressed: () => abrirDialogoLateral(CadastrarMedico(service: _medicoService)), icon: const Icon(Icons.medical_services), label: const Text("Médico")),
              ElevatedButton.icon(onPressed: () => abrirDialogoLateral(CadastrarConvenio(service: _convenioService)), icon: const Icon(Icons.business), label: const Text("Convênio")),
              ElevatedButton.icon(onPressed: () async { await abrirDialogoLateral(RealizarTriagem(pacienteService: _pacienteService, triagemService: _triagemService)); _carregarFila(); }, icon: const Icon(Icons.favorite), label: const Text("Triagem")),
              ElevatedButton.icon(onPressed: () => abrirDialogoLateral(CadastrarLeito(leitoService: _leitoService,/* alaService: _alaService*/)), icon: const Icon(Icons.bed), label: const Text("Leito")), //descomentar depois de arrumar a ala
              ElevatedButton.icon(onPressed: () => abrirDialogoLateral(const CadastrarExame()), icon: const Icon(Icons.science), label: const Text("Exame")),
              ElevatedButton.icon(onPressed: () => abrirDialogoLateral(CadastrarAlmoxarifado(service: _almoxarifadoService)), icon: Badge(isLabelVisible: _almoxarifadoService.temAlertaEstoque, label: const Icon(Icons.warning_amber_rounded, size: 12, color: Colors.white), backgroundColor: Colors.red, child: const Icon(Icons.inventory)), label: const Text("Almoxarifado")),
              ElevatedButton.icon(onPressed: () => abrirDialogoLateral(ListarAlas(service: _alaService)), icon: const Icon(Icons.house), label: const Text("Ala Medica")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _card(String title, int value, Color color) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color)),
      child: Column(
        children: [
          Text(title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text("$value",
              style: TextStyle(
                  fontSize: 26, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}