// lib/pages/pacientes/cadastrar_paciente.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../domain/entities/paciente.dart';
import '../../../domain/services/paciente_service.dart';
import '../../../domain/services/convenio_service.dart';
import '../convenios/cadastrar_convenio.dart'; // ✅ Import para abrir o cadastro rápido

class CadastrarPaciente extends StatefulWidget {
  final PacienteService service;
  final ConvenioService convenioService;
  final Paciente? pacienteEdicao;

  const CadastrarPaciente({super.key, required this.service, required this.convenioService, this.pacienteEdicao});

  @override
  State<CadastrarPaciente> createState() => _CadastrarPacienteState();
}

class _CadastrarPacienteState extends State<CadastrarPaciente> {
  final _formKey = GlobalKey<FormState>();

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

  int? _idConvenioSelecionado;
  final _carteiraCtrl = TextEditingController();
  final _validadeCtrl = TextEditingController();
  DateTime? _validadeCarteira;

  @override
  void initState() {
    super.initState();
    widget.convenioService.carregarConvenios();

    if (widget.pacienteEdicao != null) {
      final p = widget.pacienteEdicao!;
      _nomeCtrl.text = p.nome ?? '';
      _cpfCtrl.text = p.cpf ?? '';
      _alergiasCtrl.text = p.alergias ?? '';
      _tipoSanguineoCtrl.text = p.tipoSanguineo ?? '';
      _historicoCtrl.text = p.historicoClinico ?? '';
      _telefoneCtrl.text = p.telefone ?? '';
      _ruaCtrl.text = p.rua ?? '';
      _numeroCasaCtrl.text = p.numeroCasa?.toString() ?? '';
      _bairroCtrl.text = p.bairro ?? '';
      _cidadeCtrl.text = p.cidade ?? '';
      _estadoCtrl.text = p.estado ?? '';
      _cepCtrl.text = p.cep ?? '';
      _responsavelCtrl.text = p.nomeResponsavel ?? '';
      
      if (p.sexo != null) _sexoSelecionado = p.sexo![0].toUpperCase() + p.sexo!.substring(1).toLowerCase();
      
      _dataNascimento = p.nascimento;
      if (_dataNascimento != null) {
        _nascimentoCtrl.text = "${_dataNascimento!.day.toString().padLeft(2, '0')}/${_dataNascimento!.month.toString().padLeft(2, '0')}/${_dataNascimento!.year}";
      }

      _carregarConvenio(p.id!);
    }
  }

  Future<void> _carregarConvenio(int idPaciente) async {
    final vinculo = await widget.service.buscarVinculoConvenio(idPaciente);
    if (vinculo != null && mounted) {
      setState(() {
        _idConvenioSelecionado = vinculo['id_convenio'];
        _carteiraCtrl.text = vinculo['numero_carteira'] ?? '';
        if (vinculo['validade'] != null) {
          _validadeCarteira = DateTime.tryParse(vinculo['validade']);
          if (_validadeCarteira != null) {
            _validadeCtrl.text = "${_validadeCarteira!.day.toString().padLeft(2, '0')}/${_validadeCarteira!.month.toString().padLeft(2, '0')}/${_validadeCarteira!.year}";
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose(); _cpfCtrl.dispose(); _nascimentoCtrl.dispose(); _alergiasCtrl.dispose();
    _tipoSanguineoCtrl.dispose(); _historicoCtrl.dispose(); _telefoneCtrl.dispose(); _ruaCtrl.dispose();
    _numeroCasaCtrl.dispose(); _bairroCtrl.dispose(); _cidadeCtrl.dispose(); _estadoCtrl.dispose();
    _cepCtrl.dispose(); _responsavelCtrl.dispose();
    _carteiraCtrl.dispose(); _validadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? escolhida = await showDatePicker(
      context: context, initialDate: _dataNascimento ?? DateTime(2000),
      firstDate: DateTime(1900), lastDate: DateTime.now(),
    );
    if (escolhida != null) {
      setState(() {
        _dataNascimento = escolhida;
        _nascimentoCtrl.text = "${escolhida.day.toString().padLeft(2, '0')}/${escolhida.month.toString().padLeft(2, '0')}/${escolhida.year}";
      });
    }
  }

  Future<void> _selecionarValidade(BuildContext context) async {
    final DateTime? escolhida = await showDatePicker(
      context: context, initialDate: _validadeCarteira ?? DateTime.now(),
      firstDate: DateTime.now(), lastDate: DateTime(2100),
    );
    if (escolhida != null) {
      setState(() {
        _validadeCarteira = escolhida;
        _validadeCtrl.text = "${escolhida.day.toString().padLeft(2, '0')}/${escolhida.month.toString().padLeft(2, '0')}/${escolhida.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdicao = widget.pacienteEdicao != null;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(isEdicao ? Icons.edit : Icons.assignment_ind, color: Colors.teal, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      isEdicao ? "Editando Prontuário" : "Ficha de Registro Geral",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))
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
                    TextFormField(controller: _nomeCtrl, decoration: const InputDecoration(labelText: "Nome Completo *", prefixIcon: Icon(Icons.person), border: OutlineInputBorder()), validator: (v) => v == null || v.isEmpty ? "Obrigatório" : null),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: _cpfCtrl, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(labelText: "CPF *", prefixIcon: Icon(Icons.badge), border: OutlineInputBorder()), validator: (v) => v == null || v.length != 11 ? "11 dígitos" : null)),
                        const SizedBox(width: 16),
                        Expanded(child: TextFormField(controller: _telefoneCtrl, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(labelText: "Telefone", prefixIcon: Icon(Icons.phone), border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: _nascimentoCtrl, readOnly: true, onTap: () => _selecionarData(context), decoration: const InputDecoration(labelText: "Nascimento *", prefixIcon: Icon(Icons.calendar_today), border: OutlineInputBorder()), validator: (v) => v == null || v.isEmpty ? "Selecione" : null)),
                        const SizedBox(width: 16),
                        Expanded(child: DropdownButtonFormField<String>(initialValue: _sexoSelecionado, decoration: const InputDecoration(labelText: "Sexo Biológico", border: OutlineInputBorder()), items: const ['Masculino', 'Feminino', 'Outro'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => setState(() => _sexoSelecionado = v!))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(controller: _responsavelCtrl, decoration: const InputDecoration(labelText: "Responsável Legal", prefixIcon: Icon(Icons.family_restroom), border: OutlineInputBorder())),
                    const SizedBox(height: 24),
                    const Text("2. Endereço e Localização", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(flex: 3, child: TextFormField(controller: _ruaCtrl, decoration: const InputDecoration(labelText: "Rua", border: OutlineInputBorder()))),
                        const SizedBox(width: 16),
                        Expanded(flex: 1, child: TextFormField(controller: _numeroCasaCtrl, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(labelText: "Nº", border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: _bairroCtrl, decoration: const InputDecoration(labelText: "Bairro", border: OutlineInputBorder()))),
                        const SizedBox(width: 16),
                        Expanded(child: TextFormField(controller: _cidadeCtrl, decoration: const InputDecoration(labelText: "Cidade", border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: _estadoCtrl, maxLength: 2, decoration: const InputDecoration(labelText: "Estado (UF)", border: OutlineInputBorder(), counterText: ""))),
                        const SizedBox(width: 16),
                        Expanded(child: TextFormField(controller: _cepCtrl, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(labelText: "CEP", border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text("3. Ficha Clínica Inicial", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: _tipoSanguineoCtrl, decoration: const InputDecoration(labelText: "Tipo Sanguíneo", prefixIcon: Icon(Icons.bloodtype), border: OutlineInputBorder()))),
                        const SizedBox(width: 16),
                        Expanded(child: TextFormField(controller: _alergiasCtrl, decoration: const InputDecoration(labelText: "Alergias", prefixIcon: Icon(Icons.warning_amber), border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(controller: _historicoCtrl, maxLines: 3, decoration: const InputDecoration(labelText: "Histórico Clínico", alignLabelWithHint: true, border: OutlineInputBorder())),
                    
                    const SizedBox(height: 24),
                    const Text("4. Cobertura de Saúde (Opcional)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 12),
                    
                    // ✅ AQUI ESTÁ A IMPLEMENTAÇÃO DO BOTÃO DE "+" DO LADO DO CONVÊNIO
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ListenableBuilder(
                            listenable: widget.convenioService,
                            builder: (context, _) {
                              return DropdownButtonFormField<int>(
                                value: _idConvenioSelecionado,
                                decoration: const InputDecoration(labelText: "Convênio", border: OutlineInputBorder(), prefixIcon: Icon(Icons.business)),
                                items: [
                                  const DropdownMenuItem<int>(value: null, child: Text("Nenhum / Particular")),
                                  ...widget.convenioService.convenios.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nomeConvenio ?? '')))
                                ],
                                onChanged: (v) => setState(() => _idConvenioSelecionado = v),
                              );
                            }
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          height: 56, // Mesma altura do Dropdown
                          decoration: BoxDecoration(
                            color: Colors.teal,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            tooltip: "Adicionar Novo Convênio Rápido",
                            onPressed: () {
                              // Abre o modal do convênio sem fechar o modal do paciente!
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => CadastrarConvenio(service: widget.convenioService),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    if (_idConvenioSelecionado != null) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: TextFormField(controller: _carteiraCtrl, decoration: const InputDecoration(labelText: "Nº da Carteira", border: OutlineInputBorder()))),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _validadeCtrl, 
                              readOnly: true, 
                              onTap: () => _selecionarValidade(context), 
                              decoration: const InputDecoration(labelText: "Validade *", prefixIcon: Icon(Icons.calendar_today), border: OutlineInputBorder()),
                            )
                          ),
                        ],
                      )
                    ],
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
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: isEdicao ? Colors.blue : Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                  icon: Icon(isEdicao ? Icons.update : Icons.save),
                  label: Text(isEdicao ? "Atualizar Paciente" : "Salvar Prontuário"),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {

                      // ✅ AQUI ESTÁ A CORREÇÃO DO ERRO DO SQL: EXIGIR A VALIDADE!
                      if (_idConvenioSelecionado != null && _validadeCarteira == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Por favor, informe a validade da carteira do convênio!'), backgroundColor: Colors.red)
                        );
                        return; // Trava a execução para não quebrar o banco
                      }

                      try {
                        final novoPaciente = Paciente(
                          id: widget.pacienteEdicao?.id, 
                          ativo: widget.pacienteEdicao?.ativo ?? 1, 
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

                        await widget.service.salvarPaciente(
                          novoPaciente, 
                          idConvenio: _idConvenioSelecionado,
                          numeroCarteira: _carteiraCtrl.text.isEmpty ? null : _carteiraCtrl.text,
                          validade: _validadeCarteira,
                        );

                        if (context.mounted) {
                          Navigator.pop(context); 
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEdicao ? 'Paciente atualizado!' : 'Cadastrado com sucesso!'), backgroundColor: isEdicao ? Colors.blue : Colors.teal));
                        }
                      } catch (e) {
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red));
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