import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../estados/dados_globais.dart';
import '../modelos/modelos_hospitalares.dart';

class TelaFaturamento extends StatefulWidget {
  const TelaFaturamento({super.key});

  @override
  State<TelaFaturamento> createState() => _TelaFaturamentoState();
}

class _TelaFaturamentoState extends State<TelaFaturamento> {

  double _calcularTotal(Patient p) {
    double total = 0;

    for (var item in p.prescriptions) {
      total += item.total;
    }

    return total;
  }

  double _aplicarDesconto(double valor) {
    if (DadosGlobais.convenios.isEmpty) return valor;

    final conv = DadosGlobais.convenios.first;
    return valor - (valor * (conv.discount / 100));
  }

  Future<void> _gerarPDF(Patient p) async {

    final pdf = pw.Document();

    final total = _calcularTotal(p);
    final finalValue = _aplicarDesconto(total);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [

              pw.Text(
                "FATURAMENTO HOSPITALAR",
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 20),

              pw.Text("Paciente: ${p.name}"),
              pw.Text("CPF: ${p.cpf}"),
              pw.Text("Médico: ${p.doctorName ?? 'Não informado'}"),
              pw.Text("Alta: ${p.discharged ? 'Sim' : 'Não'}"),

              pw.SizedBox(height: 20),

              pw.Text(
                "ITENS UTILIZADOS:",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),

              pw.SizedBox(height: 10),

              ...p.prescriptions.map((e) {
                return pw.Text(
                  "${e.material} - Qtd: ${e.quantity} - R\$ ${e.total.toStringAsFixed(2)}",
                );
              }),

              pw.Divider(),

              pw.Text("TOTAL BRUTO: R\$ ${total.toStringAsFixed(2)}"),
              pw.Text("DESCONTO: ${DadosGlobais.convenios.isNotEmpty ? DadosGlobais.convenios.first.discount : 0}%"),

              pw.SizedBox(height: 10),

              pw.Text(
                "TOTAL FINAL: R\$ ${finalValue.toStringAsFixed(2)}",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Faturamento Hospitalar"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: DadosGlobais.pacientes.length,

        itemBuilder: (_, i) {

          final p = DadosGlobais.pacientes[i];

          final total = _calcularTotal(p);
          final finalValue = _aplicarDesconto(total);

          return Card(
            margin: const EdgeInsets.only(bottom: 15),
            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(
                    p.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text("CPF: ${p.cpf}"),
                  Text("Médico: ${p.doctorName ?? 'Não atribuído'}"),
                  Text("Alta: ${p.discharged ? 'Sim' : 'Não'}"),

                  const Divider(height: 20),

                  Text(
                    "Total bruto: R\$ ${total.toStringAsFixed(2)}",
                  ),

                  Text(
                    "Desconto: ${DadosGlobais.convenios.isNotEmpty ? DadosGlobais.convenios.first.discount : 0}%",
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "TOTAL FINAL: R\$ ${finalValue.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _gerarPDF(p),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text("Gerar PDF"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}