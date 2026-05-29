// lib/presentation/pages/tela_painel.dart
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

// Seus novos caminhos corrigidos após mover para a pasta pages
import 'tela_paciente.dart';
import '../telas/tela_mapa_leitos.dart';
import '../telas/tela_estoque.dart';
import '../telas/tela_faturamento.dart';
import '../telas/tela_cadastro_medicos.dart';
import '../telas/tela_farmacia.dart';
import '../telas/tela_atendimento_medico.dart';

// Imports da arquitetura limpa
import '../domain/services/paciente_service.dart';

class TelaPainel extends StatefulWidget {
  final Database database; // Recebe a conexão do banco do main.dart

  const TelaPainel({super.key, required this.database});

  @override
  State<TelaPainel> createState() => _TelaPainelState();
}

class _TelaPainelState extends State<TelaPainel> {
  int _selectedIndex = 0;
  late PacienteService _pacienteService;

  @override
  void initState() {
    super.initState();
    // Inicializa o serviço compartilhando a mesma conexão com o banco
    _pacienteService = PacienteService(widget.database);
    _pacienteService.carregarPacientes();
  }

  void _mostrarTriagem(String nivel, String titulo) {
    // Agora busca direto do estado reativo do seu Service (SQLite)
    // Usamos o histórico clínico onde salvamos o risco temporariamente no formulário
    final lista = _pacienteService.pacientes
        .where((p) => p.historicoClinico == nivel)
        .toList();

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
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                // Exclui ou atualiza o status no banco local
                                if (p.id != null) {
                                  await _pacienteService.deletarPaciente(p.id!);
                                }
                                if (context.mounted) Navigator.pop(context);
                              },
                              child: const Text("Dar Alta"),
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
              // Sempre que mudar de tela, força a atualização dos dados do banco
              _pacienteService.carregarPacientes();
            },
            extended: false,
            labelType: NavigationRailLabelType.none,
            destinations: const [
              NavigationRailDestination(
                icon: Tooltip(message: "Início", child: Icon(Icons.dashboard)),
                label: Text("Início"),
              ),
              NavigationRailDestination(
                icon: Tooltip(
                  message: "Farmácia",
                  child: Icon(Icons.local_pharmacy),
                ),
                label: Text("Farmácia"),
              ),
              NavigationRailDestination(
                icon: Tooltip(message: "Pacientes", child: Icon(Icons.people)),
                label: Text("Pacientes"),
              ),
              NavigationRailDestination(
                icon: Tooltip(
                  message: "Médicos",
                  child: Icon(Icons.medical_services),
                ),
                label: Text("Médicos"),
              ),
              NavigationRailDestination(
                icon: Tooltip(message: "Leitos", child: Icon(Icons.bed)),
                label: Text("Leitos"),
              ),
              NavigationRailDestination(
                icon: Tooltip(message: "Estoque", child: Icon(Icons.inventory)),
                label: Text("Estoque"),
              ),
              NavigationRailDestination(
                icon: Tooltip(
                  message: "Faturamento",
                  child: Icon(Icons.attach_money),
                ),
                label: Text("Faturamento"),
              ),
              NavigationRailDestination(
                icon: Tooltip(
                  message: "Atendimento",
                  child: Icon(Icons.healing),
                ),
                label: Text("Atendimento"),
              ),
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
      case 0:
        return _dashboard();
      case 1:
        return const TelaFarmacia();
      case 2:
        // ✅ ERRO RESOLVIDO: Passando o service instanciado para a tela de listagem/cadastro
        return TelaPaciente(service: _pacienteService);
      case 3:
        return const TelaCadastroMedicos();
      case 4:
        return const TelaMapaLeitos();
      case 5:
        return const TelaEstoque();
      case 6:
        return const TelaFaturamento();
      case 7:
        return const TelaAtendimentoMedico();
      default:
        return _dashboard();
    }
  }

  Widget _dashboard() {
    // Escuta o Service para renderizar os contadores em tempo real baseados no SQLite
    return ListenableBuilder(
      listenable: _pacienteService,
      builder: (context, _) {
        int emergencia = _pacienteService.pacientes
            .where((p) => p.historicoClinico == "Emergência")
            .length;
        int urgencia = _pacienteService.pacientes
            .where((p) => p.historicoClinico == "Urgência")
            .length;
        int poucoUrgente = _pacienteService.pacientes
            .where((p) => p.historicoClinico == "Pouco Urgente")
            .length;
        int naoUrgente = _pacienteService.pacientes
            .where((p) => p.historicoClinico == "Não Urgente")
            .length;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Painel Geral",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                children: [
                  GestureDetector(
                    onTap: () => _mostrarTriagem("Emergência", "Emergência"),
                    child: _card("Emergência", emergencia, Colors.red),
                  ),
                  GestureDetector(
                    onTap: () => _mostrarTriagem("Urgência", "Urgência"),
                    child: _card("Urgência", urgencia, Colors.orange),
                  ),
                  GestureDetector(
                    onTap: () =>
                        _mostrarTriagem("Pouco Urgente", "Pouco Urgente"),
                    child: _card(
                      "Pouco Urgente",
                      poucoUrgente,
                      Colors.yellow[700]!,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _mostrarTriagem("Não Urgente", "Não Urgente"),
                    child: _card("Não Urgente", naoUrgente, Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Wrap(
                spacing: 12,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _selectedIndex = 2),
                    icon: const Icon(Icons.person_add),
                    label: const Text("Paciente"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _selectedIndex = 3),
                    icon: const Icon(Icons.medical_services),
                    label: const Text("Médico"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Convênio em breve")),
                    ),
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
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            "$value",
            style: TextStyle(
              fontSize: 26,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
