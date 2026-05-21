import 'package:flutter/material.dart';

import '../estados/dados_globais.dart';
import '../modelos/modelos_hospitalares.dart';

class TelaCadastroMedicos extends StatefulWidget {
  const TelaCadastroMedicos({super.key});

  @override
  State<TelaCadastroMedicos> createState() => _TelaCadastroMedicosState();
}

class _TelaCadastroMedicosState extends State<TelaCadastroMedicos> {

  void _novoCadastroMedicos() {

    final nome = TextEditingController();
    final cpf = TextEditingController();
    final especialidade = TextEditingController();
    final crm = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {

        return AlertDialog(
          title: const Text("Novo Médico"),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              TextField(
                controller: nome,
                decoration: const InputDecoration(
                  labelText: "Nome",
                ),
              ),

              TextField(
                controller: cpf,
                decoration: const InputDecoration(
                  labelText: "CPF",
                ),
              ),

              TextField(
                controller: crm,
                decoration: const InputDecoration(
                  labelText: "CRM",
                ),
              ),

              TextField(
                controller: especialidade,
                decoration: const InputDecoration(
                  labelText: "Especialidade",
                ),
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
                      cpf: cpf.text,
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      floatingActionButton: FloatingActionButton(
        onPressed: _novoCadastroMedicos,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),

      body: ListView.builder(

        padding: const EdgeInsets.all(20),
        itemCount: DadosGlobais.medicos.length,

        itemBuilder: (_, i) {

          final medico = DadosGlobais.medicos[i];

          return Card(

            child: ListTile(
              title: Text(medico.name),
              subtitle: Text(medico.specialty),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          );
        },
      ),
    );
  }
}