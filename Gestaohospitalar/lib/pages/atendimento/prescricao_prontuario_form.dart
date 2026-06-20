import 'package:flutter/material.dart';
import '../../domain/services/medicamento_service.dart';

class PrescricaoProntuarioForm extends StatefulWidget {
  final Map<String, dynamic> dadosLeitoPaciente;

  const PrescricaoProntuarioForm({
    super.key,
    required this.dadosLeitoPaciente,
  });

  @override
  State<PrescricaoProntuarioForm> createState() => _PrescricaoProntuarioFormState();
}

class _PrescricaoProntuarioFormState extends State<PrescricaoProntuarioForm> {
  final _formKey = GlobalKey<FormState>();
  final _dosagemCtrl = TextEditingController();
  final _viaCtrl = TextEditingController();
  final _frequenciaCtrl = TextEditingController();
  final _observacaoCtrl = TextEditingController(); 
  
  final MedicamentoService _medicamentoService = MedicamentoService();

  List<Map<String, dynamic>> _listaMedicamentos = [];
  List<Map<String, dynamic>> _historicoPrescricoes = []; 
  Map<String, dynamic>? _medicamentoSelecionado;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDadosIniciais();
  }

  Future<void> _carregarDadosIniciais() async {
    try {
      final idProntuario = widget.dadosLeitoPaciente['id_prontuario'];
      final meds = await _medicamentoService.listarMedicamentosCatalogo();
      final historico = await _medicamentoService.listarPrescricoesPorProntuario(idProntuario);
      
      if (mounted) {
        setState(() {
          _listaMedicamentos = meds;
          _historicoPrescricoes = historico;
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _carregando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao carregar dados do banco: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _atualizarHistorico() async {
    try {
      final idProntuario = widget.dadosLeitoPaciente['id_prontuario'];
      final historico = await _medicamentoService.listarPrescricoesPorProntuario(idProntuario);
      if (mounted) {
        setState(() {
          _historicoPrescricoes = historico;
        });
      }
    } catch (e) {
      debugPrint("Erro ao atualizar histórico de prescrições: $e");
    }
  }

  void _verificarAlergia(Map<String, dynamic> medicamento) {
    String alergiasPaciente = (widget.dadosLeitoPaciente['alergias'] ?? '').toString().toLowerCase();
    String principioAtivo = (medicamento['principio_ativo'] ?? '').toString().toLowerCase();

    if (alergiasPaciente.contains(principioAtivo) && principioAtivo.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 28),
              SizedBox(width: 10),
              Text("Alerta de Alergia!", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            "Atenção! O paciente tem alergia registrada a: '${widget.dadosLeitoPaciente['alergias']}'.\n\n"
            "Evite prescrever o medicamento selecionado (${medicamento['nome']}).",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _medicamentoSelecionado = null);
              },
              child: const Text("CANCELAR PRESCRIÇÃO", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("IGNORAR E MANTER", style: TextStyle(color: Colors.orange)),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _salvarPrescricao() async {
    if (_medicamentoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione um medicamento antes de salvar."), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      try {
        final idProntuario = widget.dadosLeitoPaciente['id_prontuario'];
        final idMedico = widget.dadosLeitoPaciente['id_medico'] ?? 1;

        await _medicamentoService.prescreverMedicamento(
          idProntuario: idProntuario,
          idMedicamento: _medicamentoSelecionado!['id_medicamento'],
          idMedico: idMedico,
          dosagem: _dosagemCtrl.text,
          viaAplicacao: _viaCtrl.text,
          frequencia: _frequenciaCtrl.text,
          observacao: _observacaoCtrl.text.trim().isEmpty ? null : _observacaoCtrl.text.trim(),
        );

        // 🟢 Correção das Linhas 133 e 146: Evita quebra de contexto síncrono
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Medicamento prescrito com sucesso!"), backgroundColor: Colors.green),
        );

        _dosagemCtrl.clear();
        _viaCtrl.clear();
        _frequenciaCtrl.clear();
        _observacaoCtrl.clear(); 
        setState(() => _medicamentoSelecionado = null);

        await _atualizarHistorico();

      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao salvar prescrição: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _dosagemCtrl.dispose();
    _viaCtrl.dispose();
    _frequenciaCtrl.dispose();
    _observacaoCtrl.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Center(child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator()));
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Solicitar Nova Prescrição",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          
          DropdownButtonFormField<Map<String, dynamic>>(
            // 🟢 Correção da Linha 180: Trocado 'value' por 'initialValue' devido à depreciação
            initialValue: _medicamentoSelecionado,
            hint: const Text("Selecione um medicamento disponível..."),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              fillColor: Colors.white,
              filled: true,
            ),
            items: _listaMedicamentos.map((med) {
              return DropdownMenuItem<Map<String, dynamic>>(
                value: med,
                child: Text(med['nome'] ?? 'Sem nome'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _medicamentoSelecionado = value);
              if (value != null) _verificarAlergia(value);
            },
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _dosagemCtrl,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              labelText: "Dosagem (Ex: 500mg, 1 Frasco, 5ml)",
              fillColor: Colors.white,
              filled: true,
            ),
            validator: (v) => v == null || v.isEmpty ? "Informe a dosagem" : null,
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _viaCtrl,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              labelText: "Via de Aplicação (Ex: Oral, Intravenosa, Intramuscular)",
              fillColor: Colors.white,
              filled: true,
            ),
            validator: (v) => v == null || v.isEmpty ? "Informe a via de aplicação" : null,
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _frequenciaCtrl,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              labelText: "Frequência / Intervalo (Ex: De 8h em 8h, dose única)",
              fillColor: Colors.white,
              filled: true,
            ),
            validator: (v) => v == null || v.isEmpty ? "Informe a frequência" : null,
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _observacaoCtrl,
            maxLines: 2, 
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              labelText: "Observações / Recomendações (Opcional)",
              fillColor: Colors.white,
              filled: true,
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 55),
              backgroundColor: Colors.teal.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _salvarPrescricao,
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text("Salvar Prescrição", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          
          const Padding(
            padding: EdgeInsets.only(top: 30.0, bottom: 10.0),
            child: Text(
              "Histórico de Medicamentos Prescritos",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
            ),
          ),
          
          if (_historicoPrescricoes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "Nenhum medicamento prescrito para este prontuário.",
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true, 
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _historicoPrescricoes.length,
              itemBuilder: (context, index) {
                final prescricao = _historicoPrescricoes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1.5,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.shade50,
                      child: Icon(Icons.medication, color: Colors.teal.shade700),
                    ),
                    title: Text(
                      prescricao['nome_medicamento'] ?? 'Medicamento Indisponível',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Dosagem: ${prescricao['dosagem'] ?? 'N/A'} | Via: ${prescricao['aplicacao'] ?? 'N/A'}"),
                          Text("Horário: ${prescricao['horario'] ?? 'N/A'}", style: const TextStyle(fontWeight: FontWeight.w500)),
                          if (prescricao['observacao'] != null && prescricao['observacao'].toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                "Obs: ${prescricao['observacao']}",
                                style: TextStyle(color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}