import 'package:flutter/material.dart';
import '../../domain/services/faturamento_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ListarFaturamento extends StatefulWidget {
  final FaturamentoService service;
  const ListarFaturamento({super.key, required this.service});

  @override
  State<ListarFaturamento> createState() => _ListarFaturamentoState();
}

class _ListarFaturamentoState extends State<ListarFaturamento> {
  List<Map<String, dynamic>> _todos = [];
  List<Map<String, dynamic>> _filtrados = [];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final lista = await widget.service.listarFaturamentosComPaciente();
    setState(() {
      _todos = lista;
      _filtrados = lista;
    });
  }

  void _filtrar(String query) {
    setState(() {
      _filtrados = _todos.where((item) =>
        item['nome_paciente'].toString().toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }

  Future<void> _gerarPdf(Map<String, dynamic> f) async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(build: (ctx) => pw.Column(children: [
      pw.Text("FATURAMENTO - RECIBO", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
      pw.Text("Paciente: ${f['nome_paciente']}"),
      pw.Text("CPF: ${f['cpf']}"),
      pw.Divider(),
      pw.Text("Medicamentos: R\$ ${f['valor_medicamentos']}"),
      pw.Text("Exames: R\$ ${f['valor_exames']}"),
      pw.Text("Honorários: R\$ ${f['valor_honorarios']}"),
      pw.Divider(),
      pw.Text("TOTAL BRUTO: R\$ ${f['valor_total']}"),
      pw.Text("Status: ${f['status_pagamento']}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
    ])));
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Faturamento")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(labelText: "Buscar paciente...", border: OutlineInputBorder(), prefixIcon: Icon(Icons.search)),
              onChanged: _filtrar,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filtrados.length,
              itemBuilder: (ctx, i) {
                final f = _filtrados[i];
                final isPago = f['status_pagamento'] == 'PAGO';

                return Card(
                  child: ListTile(
                    title: Text(f['nome_paciente'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Valor: R\$ ${f['valor_total']} | Status: ${f['status_pagamento']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.picture_as_pdf, color: Colors.red), onPressed: () => _gerarPdf(f)),
                        if (!isPago)
                          IconButton(icon: const Icon(Icons.check_circle, color: Colors.green), onPressed: () async {
                            await widget.service.marcarComoPago(f['id_faturamento'], f['id_prontuario']);
                            _carregar();
                          }),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

//   Future<void> _gerarPdf(Map<String, dynamic> f) async {
//   try {
//     print("Gerando PDF para: ${f['nome_paciente']}");
//     final pdf = pw.Document();
//     // ... seu código de construção do PDF ...
//     await Printing.layoutPdf(onLayout: (format) async => pdf.save());
//   } catch (e) {
//     print("Erro ao gerar PDF: $e");
//   }
// }

}