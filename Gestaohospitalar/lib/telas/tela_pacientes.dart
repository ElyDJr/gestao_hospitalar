import 'package:flutter/material.dart';
import '../estados/dados_globais.dart';
import '../modelos/modelos_hospitalares.dart';

class TelaPacientes extends StatefulWidget {
  const TelaPacientes({super.key});

  @override
  State<TelaPacientes> createState() => _TelaPacientesState();
}

class _TelaPacientesState extends State<TelaPacientes> {
  void _novoPaciente() {
    final nome = TextEditingController();
    final idade = TextEditingController();
    final cpf = TextEditingController();
    final obs = TextEditingController();
    final hist = TextEditingController();

    String risco = "Não Urgente";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Novo Paciente"),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nome,
                      decoration: const InputDecoration(labelText: "Nome"),
                    ),
                    TextField(
                      controller: idade,
                      decoration: const InputDecoration(labelText: "Idade"),
                    ),
                    TextField(
                      controller: cpf,
                      decoration: const InputDecoration(labelText: "CPF"),
                    ),
                    TextField(
                      controller: obs,
                      decoration: const InputDecoration(labelText: "Observação"),
                    ),
                    TextField(
                      controller: hist,
                      decoration: const InputDecoration(labelText: "Histórico"),
                    ),

                    const SizedBox(height: 10),

                    DropdownButtonFormField<String>(
                      initialValue: risco,
                      decoration: const InputDecoration(
                        labelText: "Triagem",
                      ),
                      items: const [
                        "Emergência",
                        "Urgência",
                        "Pouco Urgente",
                        "Não Urgente",
                      ]
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        setDialogState(() {
                          risco = v!;
                        });
                      },
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      DadosGlobais.pacientes.add(
                        Patient(
                          name: nome.text,
                          age: idade.text,
                          cpf: cpf.text,
                          bedId: "Aguardando",
                          insurance: "Particular",
                          riskLevel: risco,
                          observation: obs.text,
                          medicalHistory: hist.text,
                        ),
                      );
                    });

                    Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pacientes"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _novoPaciente,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),

      body: ListView.builder(
  padding: const EdgeInsets.all(20),

  // 🔥 FILTRO DE ALTA AQUI
  itemCount: DadosGlobais.pacientes
      .where((p) => p.discharged == false)
      .length,

  itemBuilder: (context, i) {
    final lista = DadosGlobais.pacientes
        .where((p) => p.discharged == false)
        .toList();

    final p = lista[i];

    return Card(
      child: ListTile(
        leading: const Icon(Icons.person),
        title: Text(p.name),
        subtitle: Text("Risco: ${p.riskLevel}"),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  },
),
    );
  }
}