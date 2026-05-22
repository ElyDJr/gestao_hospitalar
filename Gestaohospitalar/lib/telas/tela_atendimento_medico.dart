import 'package:flutter/material.dart';
import '../estados/dados_globais.dart';
import '../modelos/modelos_hospitalares.dart';

class TelaAtendimentoMedico extends StatefulWidget {
  const TelaAtendimentoMedico({super.key});

  @override
  State<TelaAtendimentoMedico> createState() => _TelaAtendimentoMedicoState();
}

class _TelaAtendimentoMedicoState extends State<TelaAtendimentoMedico> {
  Patient? pacienteSelecionado;

  final evolucaoCtrl = TextEditingController();
  final exameCtrl = TextEditingController();
  final medicamentoCtrl = TextEditingController();

  void _selecionarPaciente(Patient p) {
    setState(() {
      pacienteSelecionado = p;
    });
  }

  void _salvarAtendimento() {
    if (pacienteSelecionado == null) return;

    setState(() {
      pacienteSelecionado!.evolution += "\n${evolucaoCtrl.text}";
      pacienteSelecionado!.exams += "\n${exameCtrl.text}";
      pacienteSelecionado!.medication = medicamentoCtrl.text;

      evolucaoCtrl.clear();
      exameCtrl.clear();
      medicamentoCtrl.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Atendimento salvo com sucesso")),
    );
  }

  // 🟢 NOVO: DAR ALTA
  void _darAlta() {
    if (pacienteSelecionado == null) return;

    setState(() {
      pacienteSelecionado!.discharged = true;
      pacienteSelecionado!.statusAtendimento = "alta";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Paciente recebeu alta médica")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Atendimento Médico"),
        backgroundColor: Colors.teal,
      ),

      body: Row(
        children: [
          // 📋 LISTA DE PACIENTES
          Container(
            width: 300,
            color: Colors.grey.shade200,
            child: ListView.builder(
              itemCount: DadosGlobais.pacientes.length,
              itemBuilder: (context, i) {
                final p = DadosGlobais.pacientes[i];

                return ListTile(
                  title: Text(p.name),
                  subtitle: Text("Triagem: ${p.riskLevel}"),
                  selected: pacienteSelecionado == p,
                  onTap: () => _selecionarPaciente(p),
                );
              },
            ),
          ),

          const VerticalDivider(width: 1),

          // 🩺 ÁREA DE ATENDIMENTO
          Expanded(
            child: pacienteSelecionado == null
                ? const Center(
                    child: Text("Selecione um paciente para atender"),
                  )
                : Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Paciente: ${pacienteSelecionado!.name}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text("Leito: ${pacienteSelecionado!.bedId}"),
                        Text("Triagem: ${pacienteSelecionado!.riskLevel}"),
                        Text("Status: ${pacienteSelecionado!.statusAtendimento}"),
                        Text("Alta: ${pacienteSelecionado!.discharged ? "SIM" : "NÃO"}"),

                        const SizedBox(height: 20),

                        TextField(
                          controller: evolucaoCtrl,
                          decoration: const InputDecoration(
                            labelText: "Evolução médica",
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextField(
                          controller: exameCtrl,
                          decoration: const InputDecoration(
                            labelText: "Exames solicitados",
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextField(
                          controller: medicamentoCtrl,
                          decoration: const InputDecoration(
                            labelText: "Medicação",
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _salvarAtendimento,
                              child: const Text("Salvar"),
                            ),

                            const SizedBox(width: 10),

                            // 🟢 BOTÃO DE ALTA MÉDICA
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: _darAlta,
                              child: const Text("Dar Alta Médica"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}