// lib/pages/medicos/cadastrar_medico.dart
import 'package:flutter/material.dart';
import '../../../domain/entities/medico.dart';
import '../../../domain/services/medico_service.dart';

class CadastrarMedico extends StatefulWidget {
  final MedicoService service;
  final Medico? medicoEdicao;

  const CadastrarMedico({super.key, required this.service, this.medicoEdicao});

  @override
  State<CadastrarMedico> createState() => _CadastrarMedicoState();
}

class _CadastrarMedicoState extends State<CadastrarMedico> {
  final _formKey = GlobalKey<FormState>();

  // Controladores Dados Pessoais & Profissionais
  final _nomeCtrl = TextEditingController();
  final _crmCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _cpfCtrl = TextEditingController();
  final _nascimentoCtrl = TextEditingController();
  String? _sexoSelecionado;

  // Controladores Endereço
  final _cepCtrl = TextEditingController();
  final _ruaCtrl = TextEditingController();
  final _numeroCtrl = TextEditingController();
  final _bairroCtrl = TextEditingController();
  final _cidadeCtrl = TextEditingController();
  final _estadoCtrl = TextEditingController();

  // Outros
  final _honorarioCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  String? _perfilSelecionado;
  String? _especialidadeSelecionada;

  final List<String> _sexos = ['MASCULINO', 'FEMININO', 'OUTRO'];
  final List<String> _perfisDisponiveis = [
    'ADMIN',
    'MEDICO',
    'ENFERMEIRO',
    'RECEPCAO',
    'FINANCEIRO',
    'PACIENTE'
  ];

  final List<String> _especialidadesDisponiveis = [
    'CARDIOLOGIA',
    'CLÍNICA GERAL',
    'DERMATOLOGIA',
    'GINECOLOGIA/OBSTETRÍCIA',
    'NEUROLOGIA',
    'OFTALMOLOGIA',
    'ORTOPEDIA',
    'PEDIATRIA',
    'PSIQUIATRIA',
    'UTI / INTENSIVISTA',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.medicoEdicao != null) {
      final m = widget.medicoEdicao!;
      _nomeCtrl.text = m.nome ?? '';
      _crmCtrl.text = m.crm ?? '';
      _telefoneCtrl.text = m.telefone ?? '';
      _emailCtrl.text = m.email ?? '';
      _honorarioCtrl.text = m.honorario?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _crmCtrl.dispose();
    _telefoneCtrl.dispose();
    _emailCtrl.dispose();
    _cpfCtrl.dispose();
    _nascimentoCtrl.dispose();
    _cepCtrl.dispose();
    _ruaCtrl.dispose();
    _numeroCtrl.dispose();
    _bairroCtrl.dispose();
    _cidadeCtrl.dispose();
    _estadoCtrl.dispose();
    _honorarioCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Widget _buildSecaoTitulo(String titulo) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        titulo,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
    );
  }

  Future<void> _excluirMedico() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmação'),
        content: const Text('Tem certeza que deseja excluir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('NÃO'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('SIM'),
          ),
        ],
      ),
    );

    if (confirmar == true && widget.medicoEdicao != null) {
      try {
        await widget.service.arquivarMedico(widget.medicoEdicao!);

        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('MÉDICO EXCLUÍDO COM SUCESSO!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ERRO AO EXCLUIR: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdicao = widget.medicoEdicao != null;

    return Container(
      height: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEdicao ? "EDITAR MÉDICO" : "NOVO MÉDICO",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSecaoTitulo("INFORMAÇÕES BÁSICAS"),
                    TextFormField(
                      controller: _nomeCtrl,
                      decoration: const InputDecoration(
                        labelText: "NOME COMPLETO *",
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'CAMPO OBRIGATÓRIO' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _crmCtrl,
                            decoration: const InputDecoration(
                              labelText: "CRM *",
                              prefixIcon: Icon(Icons.badge),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _especialidadeSelecionada,
                            isExpanded: true, // 🟢 Evita estouro de layout
                            decoration: const InputDecoration(
                              labelText: "ESPECIALIDADE",
                              prefixIcon: Icon(Icons.local_hospital),
                              border: OutlineInputBorder(),
                            ),
                            items: _especialidadesDisponiveis
                                .map((esp) => DropdownMenuItem(
                                      value: esp,
                                      child: Text(
                                        esp,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _especialidadeSelecionada = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cpfCtrl,
                            decoration: const InputDecoration(
                              labelText: "CPF",
                              prefixIcon: Icon(Icons.pin),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _telefoneCtrl,
                            decoration: const InputDecoration(
                              labelText: "TELEFONE",
                              prefixIcon: Icon(Icons.phone),
                              border: OutlineInputBorder(),
                            ),
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
                            decoration: const InputDecoration(
                              labelText: "NASCIMENTO (DD/MM/AAAA)",
                              prefixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _sexoSelecionado,
                            isExpanded: true, // 🟢 Evita estouro de layout
                            decoration: const InputDecoration(
                              labelText: "SEXO",
                              prefixIcon: Icon(Icons.wc),
                              border: OutlineInputBorder(),
                            ),
                            items: _sexos
                                .map((s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(
                                        s,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _sexoSelecionado = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: "E-MAIL",
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),
                    _buildSecaoTitulo("ENDEREÇO"),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cepCtrl,
                            decoration: const InputDecoration(
                              labelText: "CEP",
                              prefixIcon: Icon(Icons.map),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _ruaCtrl,
                            decoration: const InputDecoration(
                              labelText: "RUA",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _numeroCtrl,
                            decoration: const InputDecoration(
                              labelText: "NÚMERO",
                              border: OutlineInputBorder(),
                            ),
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
                              labelText: "BAIRRO",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _cidadeCtrl,
                            decoration: const InputDecoration(
                              labelText: "CIDADE",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _estadoCtrl,
                            decoration: const InputDecoration(
                              labelText: "ESTADO (UF)",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    _buildSecaoTitulo("ACESSO E PROFISSIONAL"),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _perfilSelecionado,
                            isExpanded: true, // 🟢 Evita estouro de layout
                            decoration: const InputDecoration(
                              labelText: "PERFIL",
                              prefixIcon: Icon(Icons.security),
                              border: OutlineInputBorder(),
                            ),
                            items: _perfisDisponiveis
                                .map((p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(
                                        p,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _perfilSelecionado = v),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _senhaCtrl,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: "SENHA",
                              prefixIcon: Icon(Icons.lock),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _honorarioCtrl,
                      decoration: const InputDecoration(
                        labelText: "HONORÁRIO",
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (isEdicao) ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                icon: const Icon(Icons.delete),
                label: const Text("EXCLUIR MÉDICO"),
                onPressed: _excluirMedico,
              ),
              const SizedBox(height: 12),
            ],

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isEdicao ? Colors.blue : Colors.teal,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              icon: Icon(isEdicao ? Icons.update : Icons.save),
              label: Text(isEdicao ? "ATUALIZAR MÉDICO" : "SALVAR MÉDICO"),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final medico = Medico(
                    id: widget.medicoEdicao?.id,
                    ativo: widget.medicoEdicao?.ativo ?? 1,
                    nome: _nomeCtrl.text,
                    crm: _crmCtrl.text,
                    telefone: _telefoneCtrl.text,
                    email: _emailCtrl.text,
                    honorario: double.tryParse(
                      _honorarioCtrl.text.replaceAll(',', '.'),
                    ),
                  );

                  await widget.service.salvarMedicoComEspecialidade(
                    medico,
                    _especialidadeSelecionada ?? '',
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEdicao
                              ? 'MÉDICO ATUALIZADO COM SUCESSO!'
                              : 'MÉDICO CADASTRADO COM SUCESSO!',
                        ),
                        backgroundColor: isEdicao ? Colors.blue : Colors.teal,
                      ),
                    );
                  }
                }
              },
            )
          ],
        ),
      ),
    );
  }
}