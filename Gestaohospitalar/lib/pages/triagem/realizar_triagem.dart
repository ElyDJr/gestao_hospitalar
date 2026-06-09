// lib/pages/triagem/realizar_triagem.dart
import 'package:flutter/material.dart';
import '../../../domain/entities/paciente.dart';
import '../../../domain/entities/triagem.dart';
import '../../../domain/services/paciente_service.dart';
import '../../../domain/services/triagem_service.dart';

class RealizarTriagem extends StatefulWidget {
  final PacienteService pacienteService;
  final TriagemService triagemService;

  const RealizarTriagem({super.key, required this.pacienteService, required this.triagemService});

  @override
  State<RealizarTriagem> createState() => _RealizarTriagemState();
}

class _RealizarTriagemState extends State<RealizarTriagem> {
  final _formKey = GlobalKey<FormState>();

  Paciente? _pacienteSelecionado;
  String _riscoSelecionado = 'VERDE';

  final _pressaoCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();
  final _fcCtrl = TextEditingController();
  final _satCtrl = TextEditingController();
  final _dorCtrl = TextEditingController();
  final _queixaCtrl = TextEditingController();
  final _alergiasCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  @override
  void dispose() {
    _pressaoCtrl.dispose(); _tempCtrl.dispose(); _fcCtrl.dispose(); _satCtrl.dispose();
    _dorCtrl.dispose(); _queixaCtrl.dispose(); _alergiasCtrl.dispose(); _obsCtrl.dispose();
    super.dispose();
  }

  Color _obterCorRisco(String risco) {
    switch (risco) {
      case 'VERMELHO': return Colors.red;
      case 'LARANJA': return Colors.orange;
      case 'AMARELO': return Colors.yellow.shade700;
      case 'VERDE': return Colors.green;
      case 'AZUL': return Colors.blue;
      default: return Colors.grey;
    }
  }

  String _mapearParaFila(String risco) {
    if (risco == 'VERMELHO') return 'Emergência';
    if (risco == 'LARANJA') return 'Muito Urgente'; // ✅ Corrigido
    if (risco == 'AMARELO') return 'Urgente';       // ✅ Corrigido
    if (risco == 'VERDE') return 'Pouco Urgente';
    return 'Não Urgente'; // AZUL
  }

  // ✅ Função nova e limpa: Salva a triagem como pendente para o médico
  Future<void> _enviarParaFilaMedica() async {
    if (_formKey.currentState!.validate() && _pacienteSelecionado != null) {
      try {
        final triagem = Triagem(
          idPaciente: _pacienteSelecionado!.id!,
          pressao: _pressaoCtrl.text,
          temperatura: double.tryParse(_tempCtrl.text),
          frequenciaCardiaca: int.tryParse(_fcCtrl.text),
          saturacao: int.tryParse(_satCtrl.text),
          escalaDor: int.tryParse(_dorCtrl.text),
          risco: _riscoSelecionado,
          queixa: _queixaCtrl.text,
          alergias: _alergiasCtrl.text,
          observacoes: _obsCtrl.text,
          internacao: null, // ✅ AGUARDANDO MÉDICO (No banco fica NULL)
        );

        // 1. Salva a Ficha de Triagem
        await widget.triagemService.salvarTriagem(triagem);

        // 2. Atualiza o Paciente para aparecer nos cards coloridos da Dashboard
        final pacienteAtualizado = _pacienteSelecionado!.copyWith(
          historicoClinico: _mapearParaFila(_riscoSelecionado),
        );
        await widget.pacienteService.salvarPaciente(pacienteAtualizado);
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${_pacienteSelecionado!.nome} entrou na fila de atendimento!'), backgroundColor: Colors.teal)
          );
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red));
      }
    } else if (_pacienteSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione um paciente!'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(children: [Icon(Icons.medical_information, color: Colors.teal, size: 28), SizedBox(width: 8), Text("Classificação de Risco (Enfermagem)", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal))]),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))
              ],
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<Paciente>(
                      decoration: const InputDecoration(labelText: "Paciente *", prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
                      items: widget.pacienteService.pacientes.map((p) => DropdownMenuItem(value: p, child: Text("${p.nome}"))).toList(),
                      onChanged: (p) {
                        setState(() {
                          _pacienteSelecionado = p;
                          _alergiasCtrl.text = p?.alergias ?? ''; 
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    const Text("Sinais Vitais", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: _pressaoCtrl, decoration: const InputDecoration(labelText: "PA (ex: 12x8)", border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        Expanded(child: TextFormField(controller: _tempCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Temp (°C)", border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        Expanded(child: TextFormField(controller: _fcCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "BPM", border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        Expanded(child: TextFormField(controller: _satCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Sat O2 (%)", border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: _queixaCtrl, decoration: const InputDecoration(labelText: "Queixa Principal *", border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? "Obrigatório" : null)),
                        const SizedBox(width: 16),
                        Expanded(child: TextFormField(controller: _dorCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Escala de Dor (0-10)", border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(controller: _alergiasCtrl, decoration: const InputDecoration(labelText: "Alergias Detectadas", border: OutlineInputBorder())),
                    const SizedBox(height: 16),
                    
                    const Text("Protocolo de Manchester", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: ['VERMELHO', 'LARANJA', 'AMARELO', 'VERDE', 'AZUL'].map((risco) {
                        final isSelecionado = _riscoSelecionado == risco;
                        return ChoiceChip(
                          label: Text(risco, style: TextStyle(color: isSelecionado ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                          selectedColor: _obterCorRisco(risco),
                          selected: isSelecionado,
                          onSelected: (bool selected) {
                            if (selected) setState(() => _riscoSelecionado = risco);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(controller: _obsCtrl, maxLines: 2, decoration: const InputDecoration(labelText: "Observações Iniciais", alignLabelWithHint: true, border: OutlineInputBorder())),
                  ],
                ),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
                const SizedBox(width: 16),
                
                // ✅ Botão único final da Enfermagem
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: _obterCorRisco(_riscoSelecionado), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text("Enviar p/ Fila Médica"),
                  onPressed: _enviarParaFilaMedica, // Chama a nova função
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}