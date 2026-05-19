import 'package:flutter/material.dart';
import 'package:gestaohospitalar01/modelos/modelos_hospitalares.dart';
import '../estados/dados_globais.dart';


class TelaMedicos extends StatefulWidget {
  const TelaMedicos({super.key});

  @override
  State<TelaMedicos> createState() => _TelaMedicosState();
}

class _TelaMedicosState extends State<TelaMedicos> {

  void _novoMedico() {

    final nome = TextEditingController();
    final crm = TextEditingController();
    final especialidade = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cadastrar Médico"),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            TextField(
              controller: nome,
              decoration: const InputDecoration(labelText: "Nome"),
            ),

            TextField(
              controller: crm,
              decoration: const InputDecoration(labelText: "CRM"),
            ),

            TextField(
              controller: especialidade,
              decoration: const InputDecoration(labelText: "Especialidade"),
            ),
          ],
        ),

        actions: [

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),

          ElevatedButton(
            onPressed: () {

              setState(() {

                DadosGlobais.medicos.add(
  Doctor(
    name: nome.text,
    crm: crm.text,
    specialty: especialidade.text,
                  ),
                );

              });

              Navigator.pop(context);
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Médicos"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: _novoMedico,
        child: const Icon(Icons.add),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: DadosGlobais.medicos.length,

        itemBuilder: (_, i) {

          final medico = DadosGlobais.medicos[i];

          return Card(
            child: ListTile(
              leading: const Icon(Icons.medical_services),
              title: Text(medico.name),
              subtitle: Text("${medico.specialty} | CRM ${medico.crm}"),
            ),
          );
        },
      ),
    );
  }
}