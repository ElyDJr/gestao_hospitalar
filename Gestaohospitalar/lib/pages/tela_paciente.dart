// lib/pages/tela_paciente.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../domain/entities/paciente.dart';
import '../../../domain/services/paciente_service.dart';

class TelaPaciente extends StatefulWidget {
  final PacienteService service;

  const TelaPaciente({super.key, required this.service});

  @override
  State<TelaPaciente> createState() => _TelaPacienteState();
}

class _TelaPacienteState extends State<TelaPaciente> {
  final _formKey = GlobalKey<FormState>();

  // Controllers para todos os campos do banco de dados
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
  void initState() {
    super.initState();
    widget.service.carregarPacientes();
  }

  @override
  void dispose() {
    // Limpeza de memória dos controllers
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

  // Função para abrir o seletor de data (Calendário)
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
        _nascimentoCtrl.text =
            "${escolhida.day.toString().padLeft(2, '0')}/${escolhida.month.toString().padLeft(2, '0')}/${escolhida.year}";
      });
    }
  }

  // Limpa o formulário após salvar
  void _limparCampos() {
    _nomeCtrl.clear();
    _cpfCtrl.clear();
    _nascimentoCtrl.clear();
    _alergiasCtrl.clear();
    _tipoSanguineoCtrl.clear();
    _historicoCtrl.clear();
    _telefoneCtrl.clear();
    _ruaCtrl.clear();
    _numeroCasaCtrl.clear();
    _bairroCtrl.clear();
    _cidadeCtrl.clear();
    _estadoCtrl.clear();
    _cepCtrl.clear();
    _responsavelCtrl.clear();
    _dataNascimento = null;
  }

  // Abre a cortina lateral (Drawer) com o formulário gigante e confortável
  void _abrirFormularioCadastro() {
    _limparCampos();
    showScaffoldBottomSheet();
  }

  void showScaffoldBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
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
                    // Cabeçalho do Formulário Hospitalar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.assignment_ind,
                                color: Colors.teal, size: 28),
                            SizedBox(width: 8),
                            Text(
                              "Ficha de Registro Geral de Paciente",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal),
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

                    // Corpo rolável com grid duplo para caber tudo na Web
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("1. Identificação Pessoal",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _nomeCtrl,
                              decoration: const InputDecoration(
                                  labelText: "Nome Completo *",
                                  prefixIcon: Icon(Icons.person),
                                  border: OutlineInputBorder()),
                              validator: (v) => v == null || v.isEmpty
                                  ? "Campo obrigatório"
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _cpfCtrl,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ], // APENAS NÚMEROS
                                    decoration: const InputDecoration(
                                        labelText: "CPF (Apenas números) *",
                                        prefixIcon: Icon(Icons.badge),
                                        border: OutlineInputBorder()),
                                    validator: (v) =>
                                        v == null || v.length != 11
                                            ? "CPF inválido (Digite 11 dígitos)"
                                            : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _telefoneCtrl,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ], // APENAS NÚMEROS
                                    decoration: const InputDecoration(
                                        labelText: "Telefone de Contato",
                                        prefixIcon: Icon(Icons.phone),
                                        border: OutlineInputBorder()),
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
                                    onTap: () async {
                                      await _selecionarData(context);
                                      setModalState(
                                          () {}); // Atualiza o texto do input no modal
                                    },
                                    decoration: const InputDecoration(
                                        labelText: "Data de Nascimento *",
                                        prefixIcon: Icon(Icons.calendar_today),
                                        border: OutlineInputBorder()),
                                    validator: (v) => v == null || v.isEmpty
                                        ? "Selecione a data"
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _sexoSelecionado,
                                    decoration: const InputDecoration(
                                        labelText: "Sexo Biológico",
                                        border: OutlineInputBorder()),
                                    items: const [
                                      'Masculino',
                                      'Feminino',
                                      'Outro'
                                    ]
                                        .map((s) => DropdownMenuItem(
                                            value: s, child: Text(s)))
                                        .toList(),
                                    onChanged: (v) => setModalState(
                                        () => _sexoSelecionado = v!),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _responsavelCtrl,
                              decoration: const InputDecoration(
                                  labelText:
                                      "Nome do Responsável Legal (Se menor ou incapaz)",
                                  prefixIcon: Icon(Icons.family_restroom),
                                  border: OutlineInputBorder()),
                            ),
                            const SizedBox(height: 24),
                            const Text("2. Endereço e Localização",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    controller: _ruaCtrl,
                                    decoration: const InputDecoration(
                                        labelText: "Rua / Logradouro",
                                        border: OutlineInputBorder()),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 1,
                                  child: TextFormField(
                                    controller: _numeroCasaCtrl,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ], // APENAS NÚMEROS
                                    decoration: const InputDecoration(
                                        labelText: "Nº",
                                        border: OutlineInputBorder()),
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
                                    decoration: const InputDecoration(
                                        labelText: "Bairro",
                                        border: OutlineInputBorder()),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _cidadeCtrl,
                                    decoration: const InputDecoration(
                                        labelText: "Cidade",
                                        border: OutlineInputBorder()),
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
                                    maxLength:
                                        2, // Limita a sigla do estado (Ex: SP, MG)
                                    decoration: const InputDecoration(
                                        labelText: "Estado (UF)",
                                        border: OutlineInputBorder(),
                                        counterText: ""),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _cepCtrl,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ], // APENAS NÚMEROS
                                    decoration: const InputDecoration(
                                        labelText: "CEP (Apenas números)",
                                        border: OutlineInputBorder()),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Text("3. Ficha Clínica Inicial",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _tipoSanguineoCtrl,
                                    decoration: const InputDecoration(
                                        labelText:
                                            "Tipo Sanguíneo (Ex: A+, O-)",
                                        prefixIcon: Icon(Icons.bloodtype),
                                        border: OutlineInputBorder()),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _alergiasCtrl,
                                    decoration: const InputDecoration(
                                        labelText: "Alergias Conhecidas",
                                        prefixIcon: Icon(Icons.warning_amber),
                                        border: OutlineInputBorder()),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _historicoCtrl,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                  labelText:
                                      "Histórico Clínico Pregressor / Comorbidades",
                                  alignLabelWithHint: true,
                                  border: OutlineInputBorder()),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),

                    const Divider(),
                    // Botões de Ação do Prontuário
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancelar",
                              style: TextStyle(color: Colors.grey)),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                          ),
                          icon: const Icon(Icons.save),
                          label: const Text("Salvar Prontuário"),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                // Cria o objeto Entidade pura mapeando os tipos corretos
                                final novoPaciente = Paciente(
                                  nome: _nomeCtrl.text,
                                  cpf: _cpfCtrl.text,
                                  // ✅ Converte para MAIÚSCULO para bater com o banco de dados
                                  sexo: _sexoSelecionado.toUpperCase(),
                                  nascimento: _dataNascimento,
                                  alergias: _alergiasCtrl.text.isEmpty
                                      ? null
                                      : _alergiasCtrl.text,
                                  tipoSanguineo: _tipoSanguineoCtrl.text.isEmpty
                                      ? null
                                      : _tipoSanguineoCtrl.text,
                                  historicoClinico: _historicoCtrl.text.isEmpty
                                      ? null
                                      : _historicoCtrl.text,
                                  telefone: _telefoneCtrl.text.isEmpty
                                      ? null
                                      : _telefoneCtrl.text,
                                  rua: _ruaCtrl.text.isEmpty
                                      ? null
                                      : _ruaCtrl.text,
                                  numeroCasa: _numeroCasaCtrl.text.isEmpty
                                      ? null
                                      : int.tryParse(_numeroCasaCtrl.text),
                                  bairro: _bairroCtrl.text.isEmpty
                                      ? null
                                      : _bairroCtrl.text,
                                  cidade: _cidadeCtrl.text.isEmpty
                                      ? null
                                      : _cidadeCtrl.text,
                                  estado: _estadoCtrl.text.isEmpty
                                      ? null
                                      : _estadoCtrl.text,
                                  // ✅ Garante que o CEP só seja salvo se tiver exatamente 8 números
                                  cep: _cepCtrl.text.length == 8
                                      ? _cepCtrl.text
                                      : null,
                                  nomeResponsavel: _responsavelCtrl.text.isEmpty
                                      ? null
                                      : _responsavelCtrl.text,
                                );

                                // Salva no banco de dados através do Service
                                await widget.service
                                    .salvarPaciente(novoPaciente);

                                if (context.mounted) {
                                  Navigator.pop(context); // Fecha o modal
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Paciente registrado com sucesso no SQLite!'),
                                        backgroundColor: Colors.teal),
                                  );
                                }
                              } catch (e) {
                                // 🚨 CAPTURA E EXIBE O ERRO DO BANCO DE DADOS NA TELA
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Erro ao salvar no banco: $e'),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(
                                          seconds:
                                              6), // Fica 6 segundos na tela
                                    ),
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
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.service,
      builder: (context, _) {
        if (widget.service.isLoading) {
          return const Scaffold(
              body:
                  Center(child: CircularProgressIndicator(color: Colors.teal)));
        }

        final lista = widget.service.pacientes;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Central de Cadastro de Pacientes"),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _abrirFormularioCadastro,
            backgroundColor: Colors.teal,
            icon: const Icon(Icons.person_add, color: Colors.white),
            label: const Text("Registrar Novo Paciente",
                style: TextStyle(color: Colors.white)),
          ),
          body: lista.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open, size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                          "Nenhum prontuário encontrado no banco de dados local.",
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: lista.length,
                  itemBuilder: (context, i) {
                    final p = lista[i];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(p.nome ?? 'Sem Nome',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            "CPF: ${p.cpf} | Cidade: ${p.cidade ?? 'Não Informada'}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (p.tipoSanguineo != null)
                              Chip(
                                label: Text(p.tipoSanguineo!),
                                backgroundColor:
                                    Colors.red.withValues(alpha: 0.1),
                                labelStyle: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () async {
                                if (p.id != null) {
                                  await widget.service.deletarPaciente(p.id!);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
