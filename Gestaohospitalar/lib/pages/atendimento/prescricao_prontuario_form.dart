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
  // 🟢 Controlador adicionado para a observação
  final _observacaoCtrl = TextEditingController(); 
  
  // Instância do novo serviço
  final MedicamentoService _medicamentoService = MedicamentoService();

  List<Map<String, dynamic>> _listaMedicamentos = [];
  Map<String, dynamic>? _medicamentoSelecionado;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarMedicamentosDoBanco();
  }

  Future<void> _carregarMedicamentosDoBanco() async {
    try {
      final meds = await _medicamentoService.listarMedicamentosCatalogo();
      if (mounted) {
        setState(() {
          _listaMedicamentos = meds;
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _carregando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao carregar medicamentos: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _verificarAlergia(Map<String, dynamic> medicamento) {
    String alergiasPaciente = (widget.dadosLeitoPaciente['alergias'] ?? '').toString().toLowerCase();
    String principioAtivo = (medicamento['principio_ativo'] ?? '').toString().toLowerCase();

    // Se o princípio ativo do remédio estiver na string de alergias do paciente
    if (alergiasPaciente.contains(principioAtivo) && principioAtivo.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            children: const [
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
          // 🟢 Passando a observação para o serviço (se estiver vazia, envia null)
          observacao: _observacaoCtrl.text.trim().isEmpty ? null : _observacaoCtrl.text.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Medicamento prescrito com sucesso!"), backgroundColor: Colors.green),
        );

        // Limpa os campos após salvar
        _dosagemCtrl.clear();
        _viaCtrl.clear();
        _frequenciaCtrl.clear();
        _observacaoCtrl.clear(); // 🟢 Limpa o campo de observação
        setState(() => _medicamentoSelecionado = null);

      } catch (e) {
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
    _observacaoCtrl.dispose(); // 🟢 Desaloca o controlador da observação
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
          
          // Dropdown de seleção de medicamento
          DropdownButtonFormField<Map<String, dynamic>>(
            value: _medicamentoSelecionado,
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

          // Campo de Dosagem
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

          // Campo de Via de Aplicação
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

          // Campo de Frequência/Horário
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

          // 🟢 Novo Campo de Observação (Opcional)
          TextFormField(
            controller: _observacaoCtrl,
            maxLines: 2, // Permite que o campo quebre linhas caso o texto seja longo
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              labelText: "Observações / Recomendações (Opcional)",
              fillColor: Colors.white,
              filled: true,
            ),
          ),
          const SizedBox(height: 24),

          // Botão Salvar Prescrição
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
        ],
      ),
    );
  }
}