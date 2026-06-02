// lib/pages/paciente/cadastrar_paciente.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../domain/entities/paciente.dart';
import '../../../domain/services/paciente_service.dart';

class CadastrarPaciente extends StatefulWidget {
  final PacienteService service;

  const CadastrarPaciente({super.key, required this.service});

  @override
  State<CadastrarPaciente> createState() => _CadastrarPacienteState();
}

class _CadastrarPacienteState extends State<CadastrarPaciente> {
  final _formKey = GlobalKey<FormState>();

  // Controllers criados "fresquinhos" toda vez que a tela abre
  final _nomeCtrl = TextEditingController();
  final _cpfCtrl = TextEditingController();
  final _nascimentoCtrl = TextEditingController();
  final _alergiasCtrl = TextEditingController();
  final _tipoSanguineoCtrl = TextEditingController();
  final _historicoCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  final _ruaCtrl = TextEditingController();
  final _numeroCasaCtrl = TextEditingController();
  final _bairroCtrl = TextEditingController();
  final _cidadeCtrl = TextEditingController();
  final _estadoCtrl = TextEditingController();
  final _cepCtrl = TextEditingController();
  final _responsavelCtrl = TextEditingController();
  
  String _sexoSelecionado = 'Masculino';
  DateTime? _dataNascimento;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _cpfCtrl.dispose();
    _nascimentoCtrl.dispose();
    _alergiasCtrl.dispose();
    _tipoSanguineoCtrl.dispose();
    _historicoCtrl.dispose();
    _telefoneCtrl.dispose();
    _ruaCtrl.dispose();
    _numeroCasaCtrl.dispose();
    _bairroCtrl.dispose();
    _cidadeCtrl.dispose();
    _estadoCtrl.dispose();
    _cepCtrl.dispose();
    _responsavelCtrl.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? escolhida = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (escolhida != null && escolhida != _dataNascimento) {
      setState(() {
        _dataNascimento = escolhida;
        _nascimentoCtrl.text = "${escolhida.day.toString().padLeft(2, '0')}/${escolhida.month.toString().padLeft(2, '0')}/${escolhida.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.assignment_ind, color: Colors.teal, size: 28),
                    SizedBox(width: 8),
                    Text(
                      "Registro Geral de Paciente",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const Divider(height: 30),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("1. Identificação Pessoal", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 12),
                    
                    TextFormField(
                      controller: _nomeCtrl,
                      decoration: const InputDecoration(labelText: "Nome Completo *", prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
                      validator: (v) => v == null || v.isEmpty ? "Campo obrigatório" : null,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cpfCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(labelText: "CPF (Apenas números) *", prefixIcon: Icon(Icons.badge), border: OutlineInputBorder()),
                            validator: (v) => v == null || v.length != 11 ? "CPF inválido (11 dígitos)" : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _telefoneCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(labelText: "Telefone de Contato", prefixIcon: Icon(Icons.phone), border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _nascimentoCtrl,
                            readOnly: true,
                            onTap: () => _selecionarData(context),
                            decoration: const InputDecoration(labelText: "Data de Nascimento *", prefixIcon: Icon(Icons.calendar_today), border: OutlineInputBorder()),
                            validator: (v) => v == null || v.isEmpty ? "Selecione a data" : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _sexoSelecionado,
                            decoration: const InputDecoration(labelText: "Sexo Biológico", border: OutlineInputBorder()),
                            items: const ['Masculino', 'Feminino', 'Outro']
                                .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (v) => setState(() => _sexoSelecionado = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _responsavelCtrl,
                      decoration: const InputDecoration(labelText: "Nome do Responsável Legal (Se menor/incapaz)", prefixIcon: Icon(Icons.family_restroom), border: OutlineInputBorder()),
                    ),

                    const SizedBox(height: 24),
                    const Text("2. Endereço e Localização", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _ruaCtrl,
                            decoration: const InputDecoration(labelText: "Rua / Logradouro", border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: _numeroCasaCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(labelText: "Nº", border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _bairroCtrl,
                            decoration: const InputDecoration(labelText: "Bairro", border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _cidadeCtrl,
                            decoration: const InputDecoration(labelText: "Cidade", border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _estadoCtrl,
                            maxLength: 2,
                            decoration: const InputDecoration(labelText: "Estado (UF)", border: OutlineInputBorder(), counterText: ""),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _cepCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(labelText: "CEP (Apenas números)", border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Text("3. Ficha Clínica Inicial", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _tipoSanguineoCtrl,
                            decoration: const InputDecoration(labelText: "Tipo Sanguíneo (Ex: A+, O-)", prefixIcon: Icon(Icons.bloodtype), border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _alergiasCtrl,
                            decoration: const InputDecoration(labelText: "Alergias Conhecidas", prefixIcon: Icon(Icons.warning_amber), border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _historicoCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: "Histórico Clínico Pregressor / Comorbidades", alignLabelWithHint: true, border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  icon: const Icon(Icons.save),
                  label: const Text("Salvar Prontuário"),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final novoPaciente = Paciente(
                          nome: _nomeCtrl.text,
                          cpf: _cpfCtrl.text,
                          sexo: _sexoSelecionado.toUpperCase(),
                          nascimento: _dataNascimento,
                          alergias: _alergiasCtrl.text.isEmpty ? null : _alergiasCtrl.text,
                          tipoSanguineo: _tipoSanguineoCtrl.text.isEmpty ? null : _tipoSanguineoCtrl.text,
                          historicoClinico: _historicoCtrl.text.isEmpty ? null : _historicoCtrl.text,
                          telefone: _telefoneCtrl.text.isEmpty ? null : _telefoneCtrl.text,
                          rua: _ruaCtrl.text.isEmpty ? null : _ruaCtrl.text,
                          numeroCasa: _numeroCasaCtrl.text.isEmpty ? null : int.tryParse(_numeroCasaCtrl.text),
                          bairro: _bairroCtrl.text.isEmpty ? null : _bairroCtrl.text,
                          cidade: _cidadeCtrl.text.isEmpty ? null : _cidadeCtrl.text,
                          estado: _estadoCtrl.text.isEmpty ? null : _estadoCtrl.text,
                          cep: _cepCtrl.text.length == 8 ? _cepCtrl.text : null,
                          nomeResponsavel: _responsavelCtrl.text.isEmpty ? null : _responsavelCtrl.text,
                        );

                        await widget.service.salvarPaciente(novoPaciente);
                        
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Paciente registrado com sucesso!'), backgroundColor: Colors.teal),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erro ao salvar no banco: $e'), backgroundColor: Colors.red, duration: const Duration(seconds: 6)),
                          );
                        }
                      }
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}