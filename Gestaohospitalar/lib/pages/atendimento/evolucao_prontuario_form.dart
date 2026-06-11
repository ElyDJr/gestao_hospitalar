import 'package:flutter/material.dart';
import '../../domain/services/leito_service.dart';

class ProntuarioEvolucaoForm extends StatefulWidget {
  final Map<String, dynamic> dadosLeitoPaciente;

  const ProntuarioEvolucaoForm({super.key, required this.dadosLeitoPaciente});

  @override
  State<ProntuarioEvolucaoForm> createState() => _ProntuarioEvolucaoFormState();
}

class _ProntuarioEvolucaoFormState extends State<ProntuarioEvolucaoForm> {
  final _evolucaoCtrl = TextEditingController();
  final LeitoService _leitoService = LeitoService();

  @override
  void initState() {
    super.initState();
    // Carrega a evolução anterior, se houver
    _evolucaoCtrl.text = widget.dadosLeitoPaciente['evolucao'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.dadosLeitoPaciente;

    return Scaffold(
      appBar: AppBar(
        title: Text("Leito ${d['numero_leito']} - Prontuário Médico"),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. DADOS DO PACIENTE
            Card(
              child: ListTile(
                leading: const Icon(Icons.person, size: 40, color: Colors.blue),
                title: Text("Paciente: ${d['nome']}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Text(
                    "CPF: ${d['cpf']}\nData de Admissão: ${d['data_abertura']?.split('T')[0] ?? 'N/A'}"),
              ),
            ),

            // 2. SINAIS VITAIS E TRIAGEM
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Sinais Vitais (Entrada)",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const Divider(),
                    Text(
                        "Pressão: ${d['pressao']} | Temp: ${d['temperatura']}°C | Sat: ${d['saturacao']}% | FC: ${d['frequencia_cardiaca']}bpm"),
                    const SizedBox(height: 10),
                    Text("Queixa Principal: ${d['queixa']}",
                        style: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold)),
                    Text("Alergias: ${d['alergias'] ?? 'Nenhuma relatada'}"),
                    Text(
                        "Risco de Evasão: ${d['risco_evasao']} | Isolamento: ${d['isolamento']}"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 3. EVOLUÇÃO MÉDICA
            const Text("Evolução Clínica e Conduta",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextFormField(
              controller: _evolucaoCtrl,
              maxLines: 15,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText:
                    "Digite a evolução médica, prescrições e conduta de hoje...",
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.teal),
              onPressed: _salvarEvolucao,
              child: const Text("Salvar Evolução",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }

  void _salvarEvolucao() async {
    try {
      await _leitoService.atualizarEvolucaoProntuario(
        widget.dadosLeitoPaciente['id_prontuario'],
        _evolucaoCtrl.text,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Evolução salva com sucesso!"),
            backgroundColor: Colors.green));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red));
    }
  }
}
