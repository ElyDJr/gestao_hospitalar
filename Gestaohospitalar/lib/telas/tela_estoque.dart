import 'package:flutter/material.dart';

import '../estados/dados_globais.dart';
import '../modelos/modelos_hospitalares.dart';

class TelaEstoque extends StatefulWidget {
  const TelaEstoque({super.key});

  @override
  State<TelaEstoque> createState() => _TelaEstoqueState();
}

class _TelaEstoqueState extends State<TelaEstoque> {

  void _adicionarItem() {

    final nome = TextEditingController();
    final qtd = TextEditingController();
    final preco = TextEditingController();
    String categoria = "Médico";

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {

          return AlertDialog(
            title: const Text("Adicionar Item"),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                TextField(
                  controller: nome,
                  decoration: const InputDecoration(labelText: "Nome"),
                ),

                TextField(
                  controller: qtd,
                  decoration: const InputDecoration(labelText: "Quantidade"),
                  keyboardType: TextInputType.number,
                ),

                TextField(
                  controller: preco,
                  decoration: const InputDecoration(labelText: "Preço"),
                  keyboardType: TextInputType.number,
                ),

                DropdownButton<String>(
                  value: categoria,
                  isExpanded: true,
                  items: const [
                    "Médico",
                    "Limpeza",
                    "EPI",
                    "Medicamento",
                  ].map((e) {
                    return DropdownMenuItem(value: e, child: Text(e));
                  }).toList(),
                  onChanged: (v) {
                    setStateDialog(() {
                      categoria = v!;
                    });
                  },
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
                    DadosGlobais.estoque.add(
                      StockItem(
                        name: nome.text,
                        category: categoria,
                        quantity: int.tryParse(qtd.text) ?? 0,
                        price: double.tryParse(preco.text) ?? 0,
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
      ),
    );
  }

  void _editarItem(StockItem item) {

    final qtd = TextEditingController(text: item.quantity.toString());
    final preco = TextEditingController(text: item.price.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Editar ${item.name}"),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            TextField(
              controller: qtd,
              decoration: const InputDecoration(labelText: "Quantidade"),
              keyboardType: TextInputType.number,
            ),

            TextField(
              controller: preco,
              decoration: const InputDecoration(labelText: "Preço"),
              keyboardType: TextInputType.number,
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
                item.quantity = int.tryParse(qtd.text) ?? item.quantity;
                item.price = double.tryParse(preco.text) ?? item.price;
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
        title: const Text("Estoque"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _adicionarItem,
          )
        ],
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: DadosGlobais.estoque.length,

        itemBuilder: (_, i) {

          final item = DadosGlobais.estoque[i];

          return Card(
            child: ListTile(
              title: Text(item.name),
              subtitle: Text(
                "${item.category} | Qtd: ${item.quantity} | R\$ ${item.price}",
              ),

              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editarItem(item),
              ),
            ),
          );
        },
      ),
    );
  }
}