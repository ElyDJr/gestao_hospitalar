import 'package:flutter/material.dart';

import 'tela_pacientes.dart';
import 'tela_mapa_leitos.dart';
import 'tela_estoque.dart';
import 'tela_faturamento.dart';
import '../estados/dados_globais.dart';

class TelaPainel extends StatefulWidget {
  const TelaPainel({super.key});

  @override
  State<TelaPainel> createState() => _TelaPainelState();
}

class _TelaPainelState extends State<TelaPainel> {

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
  appBar: AppBar(
    title: const Text("MONGE - GESTÃO HOSPITALAR"),
    backgroundColor: Colors.teal,
    foregroundColor: Colors.white,
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 10),
        child: IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {

            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Login do Usuário"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [

                    TextField(
                      decoration: InputDecoration(labelText: "Usuário"),
                    ),

                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(labelText: "Senha"),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancelar"),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Entrar"),
                  ),
                ],
              ),
            );

          },
        ),
      ),
    ],
  ),

  body: Row(
    children: [

      NavigationRail(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) {
          setState(() => _selectedIndex = i);
            },
            extended: MediaQuery.of(context).size.width > 1000,
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text("Início")),
              NavigationRailDestination(icon: Icon(Icons.people), label: Text("Pacientes")),
              NavigationRailDestination(icon: Icon(Icons.bed), label: Text("Leitos")),
              NavigationRailDestination(icon: Icon(Icons.inventory), label: Text("Estoque")),
              NavigationRailDestination(icon: Icon(Icons.attach_money), label: Text("Faturamento")),
            ],
          ),

          const VerticalDivider(width: 1),

          Expanded(
            child: _getPage(_selectedIndex),
          ),
        ],
      ),
    );
  }

  Widget _getPage(int index) {

    switch (index) {
      case 0:
        return _dashboard();

      case 1:
        return const TelaPacientes();

      case 2:
        return const TelaMapaLeitos();

      case 3:
        return const TelaEstoque();

      case 4:
        return const TelaFaturamento();

      default:
        return _dashboard();
    }
  }

  Widget _dashboard() {

    int emergencia = DadosGlobais.pacientes.where((p) => p.riskLevel == "Emergência").length;
    int urgencia = DadosGlobais.pacientes.where((p) => p.riskLevel == "Urgência").length;
    int poucoUrgente = DadosGlobais.pacientes.where((p) => p.riskLevel == "Pouco Urgente").length;
    int naoUrgente = DadosGlobais.pacientes.where((p) => p.riskLevel == "Não Urgente").length;

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

              _card("Emergência", emergencia, Colors.red),
              _card("Urgência", urgencia, Colors.orange),
              _card("Pouco Urgente", poucoUrgente, Colors.yellow),
              _card("Não Urgente", naoUrgente, Colors.green),
            ],
          ),

          const SizedBox(height: 30),

          Wrap(
            spacing: 12,
            children: [

              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _selectedIndex = 1);
                },
                icon: const Icon(Icons.person_add),
                label: const Text("Cadastrar Paciente"),
              ),

              ElevatedButton.icon(
                onPressed: () {
                  _showMedicalForm();
                },
                icon: const Icon(Icons.medical_services),
                label: const Text("Atendimento Médico"),
              ),

              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Cadastro de convênio (em breve)")),
                  );
                },
                icon: const Icon(Icons.business),
                label: const Text("Convênio"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMedicalForm() {

  String? selectedPatient;
  final medicineCtrl = TextEditingController();
  bool alta = false;

  showDialog(
    context: context,
    builder: (ctx) {

      return StatefulBuilder(
        builder: (context, setStateDialog) {

          return AlertDialog(
            title: const Text("Atendimento Médico"),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                DropdownButton<String>(
                  value: selectedPatient,
                  hint: const Text("Selecionar Paciente"),
                  isExpanded: true,
                  items: DadosGlobais.pacientes.map((p) {
                    return DropdownMenuItem(
                      value: p.name,
                      child: Text(p.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setStateDialog(() {
                      selectedPatient = val;
                    });
                  },
                ),

                TextField(
                  controller: medicineCtrl,
                  decoration: const InputDecoration(labelText: "Medicamento"),
                ),

                SwitchListTile(
                  title: const Text("Dar Alta Médica"),
                  value: alta,
                  onChanged: (val) {
                    setStateDialog(() {
                      alta = val;
                    });
                  },
                ),
              ],
            ),

            actions: [

              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancelar"),
              ),

              ElevatedButton(
                onPressed: selectedPatient == null
                    ? null
                    : () {

                        final paciente = DadosGlobais.pacientes.firstWhere(
                          (p) => p.name == selectedPatient,
                        );

                        // 🔥 NÃO SOBRESCREVER HISTÓRICO
                        paciente.medicalHistory =
                            "${paciente.medicalHistory}\nMedicamento: ${medicineCtrl.text}";

                        paciente.medication = medicineCtrl.text;

                        paciente.discharged = alta;

                        setState(() {});

                        Navigator.pop(ctx);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Atendimento registrado")),
                        );
                      },
                child: const Text("Salvar"),
                ),
              ],
            );
          },
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
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text("$value", style: TextStyle(fontSize: 26, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}