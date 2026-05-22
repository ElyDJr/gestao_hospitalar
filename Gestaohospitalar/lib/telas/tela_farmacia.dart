import 'package:flutter/material.dart';
import '../estados/dados_globais.dart';

class TelaFarmacia extends StatefulWidget {
  const TelaFarmacia({super.key});

  @override
  State<TelaFarmacia> createState() => _TelaFarmaciaState();
}

class _TelaFarmaciaState extends State<TelaFarmacia> {

  final prontuarioCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Farmácia"),
        backgroundColor: Colors.teal,
      ),

      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: prontuarioCtrl,
              decoration: const InputDecoration(
                labelText: "ID Prontuário (obrigatório)",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: DadosGlobais.estoque.length,
              itemBuilder: (context, i) {
                final item = DadosGlobais.estoque[i];

                return Card(
                  child: ListTile(
                    title: Text(item.name),
                    subtitle: Text("Qtd: ${item.quantity}"),

                    onTap: () {
                      final qtdCtrl = TextEditingController();
                      final obsCtrl = TextEditingController();

                      showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: Text(item.name),

                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [

                                TextField(
                                  controller: qtdCtrl,
                                  decoration: const InputDecoration(
                                    labelText: "Quantidade",
                                  ),
                                ),

                                TextField(
                                  controller: obsCtrl,
                                  decoration: const InputDecoration(
                                    labelText: "Observação",
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
                                  if (prontuarioCtrl.text.isEmpty) return;

                                  Navigator.pop(context);
                                },
                                child: const Text("Adicionar"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}