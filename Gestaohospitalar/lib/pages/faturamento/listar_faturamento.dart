import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../domain/services/faturamento_service.dart';
import '../../data/resources/database_provider.dart';

class ListarFaturamento extends StatefulWidget {
  final FaturamentoService service;
  const ListarFaturamento({super.key, required this.service});
  @override
  State<ListarFaturamento> createState() => _ListarFaturamentoState();
}

class _ListarFaturamentoState extends State<ListarFaturamento> {
  List<Map<String, dynamic>> _lista = [];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final db = await DatabaseProvider.instance.database;
    final dados = await db.rawQuery('''
      SELECT f.*, p.nome as nome_paciente, p.cpf
      FROM faturamento f
      JOIN prontuario pr ON f.id_prontuario = pr.id_prontuario
      JOIN paciente p ON pr.id_paciente = p.id_paciente
    ''');
    setState(() => _lista = dados);
  }

  Future<void> _gerarPDF(Map<String, dynamic> f) async {
    final service = FaturamentoService(await DatabaseProvider.instance.database);
    final calc = await service.calcularConta(f['id_prontuario'], f['id_internacao']);
    
    final pdf = pw.Document();
    pdf.addPage(pw.Page(build: (ctx) => pw.Column(children: [
      pw.Text("RELATÓRIO DE FATURAMENTO", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
      pw.Text("Paciente: ${f['nome_paciente']}"),
      pw.Divider(),
      pw.Text("Honorários Médicos: R\$ ${calc['honorarios'].toStringAsFixed(2)}"),
      pw.Text("Exames: R\$ ${calc['exames'].toStringAsFixed(2)}"),
      pw.Text("Consumo/Medicação: R\$ ${calc['consumo'].toStringAsFixed(2)}"),
      pw.Divider(),
      pw.Text("TOTAL BRUTO: R\$ ${calc['total_bruto'].toStringAsFixed(2)}"),
      pw.Text("COBERTURA PLANO: - R\$ ${calc['desconto_plano'].toStringAsFixed(2)}"),
      pw.SizedBox(height: 10),
      pw.Text("TOTAL A PAGAR: R\$ ${calc['total_a_pagar'].toStringAsFixed(2)}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
    ])));
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Faturamento")),
      body: ListView.builder(
        itemCount: _lista.length,
        itemBuilder: (_, i) {
          final f = _lista[i];
          return Card(
            child: ListTile(
              title: Text(f['nome_paciente']),
              subtitle: Text("Data: ${f['data_fechamento']}"),
              trailing: IconButton(icon: const Icon(Icons.picture_as_pdf), onPressed: () => _gerarPDF(f)),
            ),
          );
        },
      ),
    );
  }
}