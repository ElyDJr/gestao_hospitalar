import 'package:flutter/material.dart';
import '../modelos/modelos_hospitalares.dart';
import '../estados/dados_globais.dart';

class TelaConvenios extends StatefulWidget {
  const TelaConvenios({super.key});

  @override
  State<TelaConvenios> createState() => _TelaConveniosState();
}

class _TelaConveniosState extends State<TelaConvenios> {

  void _novoConvenio() {

    final nome = TextEditingController();
    final tipoPlano = TextEditingController();
    final valorConsulta = TextEditingController();
    final desconto = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cadastrar Convênio"),

        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              TextField(
                controller: nome,
                decoration: const InputDecoration(
                  labelText: "Nome do Convênio",
                ),
              ),

              TextField(
                controller: tipoPlano,
                decoration: const InputDecoration(
                  labelText: "Tipo de Plano",
                ),
              ),

              TextField(
                controller: valorConsulta,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Valor da Consulta",
                ),
              ),

              TextField(
                controller: desconto,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Desconto (%)",
                ),
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

                DadosGlobais.convenios.add(

                  Insurance(
                    name: nome.text,
                    planType: tipoPlano.text,
                    consultationPrice: double.tryParse(valorConsulta.text) ?? 0,
                    discount: double.tryParse(desconto.text) ?? 0,
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        onPressed: _novoConvenio,
        child: const Icon(Icons.add),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: DadosGlobais.convenios.length,

        itemBuilder: (_, i) {

          final convenio = DadosGlobais.convenios[i];

          return Card(
            child: ListTile(
              leading: const Icon(Icons.business),
              title: Text(convenio.name),
              subtitle: Text(
                "${convenio.planType} | "
                "Consulta: R\$ ${convenio.consultationPrice.toStringAsFixed(2)} | "
                "Desconto: ${convenio.discount.toStringAsFixed(0)}%",
              ),
            ),
          );
        },
      ),
    );
  }
}