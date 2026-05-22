import 'package:flutter/material.dart';

import 'tela_pacientes.dart';
import 'tela_mapa_leitos.dart';
import 'tela_estoque.dart';
import 'tela_faturamento.dart';
import '../estados/dados_globais.dart';
import 'tela_cadastro_medicos.dart';
import 'tela_farmacia.dart';
import 'tela_atendimento_medico.dart';

class TelaPainel extends StatefulWidget {
  const TelaPainel({super.key});

  @override
  State<TelaPainel> createState() => _TelaPainelState();
}

class _TelaPainelState extends State<TelaPainel> {
  int _selectedIndex = 0;

  void _mostrarTriagem(String nivel, String titulo) {
    final lista = DadosGlobais.pacientes
    .where((p) =>
        p.riskLevel == nivel &&
        p.discharged == false)
    .toList();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
                        title: Text(p.name),
                        subtitle: Text(
                          "Leito: ${p.bedId} | Status: ${p.statusAtendimento}",
                        ),

                        // ✅ BOTÃO DE ALTA ADICIONADO AQUI
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () {
                            setState(() {
                              p.statusAtendimento = "alta";
                              p.discharged = true;
                            });

                            Navigator.pop(context);
                          },
                          child: const Text("Dar Alta"),
                        ),
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
      ),

      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) {
              setState(() => _selectedIndex = i);
            },
            extended: false,
            labelType: NavigationRailLabelType.none,
            destinations: const [
              NavigationRailDestination(
                icon: Tooltip(message: "Início", child: Icon(Icons.dashboard)),
                label: Text("Início"),
              ),
              NavigationRailDestination(
                icon: Tooltip(message: "Farmácia", child: Icon(Icons.local_pharmacy)),
                label: Text("Farmácia"),
              ),
              NavigationRailDestination(
                icon: Tooltip(message: "Pacientes", child: Icon(Icons.people)),
                label: Text("Pacientes"),
              ),
              NavigationRailDestination(
                icon: Tooltip(message: "Médicos", child: Icon(Icons.medical_services)),
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
                icon: Tooltip(message: "Faturamento", child: Icon(Icons.attach_money)),
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
        return const TelaPacientes();
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
    int emergencia =
    DadosGlobais.pacientes
        .where((p) =>
            p.riskLevel == "Emergência" &&
            p.discharged == false)
        .length;

int urgencia =
    DadosGlobais.pacientes
        .where((p) =>
            p.riskLevel == "Urgência" &&
            p.discharged == false)
        .length;

int poucoUrgente =
    DadosGlobais.pacientes
        .where((p) =>
            p.riskLevel == "Pouco Urgente" &&
            p.discharged == false)
        .length;

int naoUrgente =
    DadosGlobais.pacientes
        .where((p) =>
            p.riskLevel == "Não Urgente" &&
            p.discharged == false)
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
                onTap: () => _mostrarTriagem("Pouco Urgente", "Pouco Urgente"),
                child: _card("Pouco Urgente", poucoUrgente, Colors.yellow),
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
  }

  Widget _card(String title, int value, Color color) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
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