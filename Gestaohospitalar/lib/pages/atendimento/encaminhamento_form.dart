import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../domain/services/sala_service.dart';
import '../../domain/services/leito_service.dart';
import '../../domain/services/ala_service.dart';
import '../../domain/entities/sala.dart';
import '../../domain/entities/leito.dart';
import '../../domain/entities/ala.dart';
import '../../domain/entities/paciente.dart';
import '../../domain/services/medico_service.dart';
import '../../domain/entities/medico.dart';

class EncaminhamentoForm extends StatefulWidget {
  final Paciente paciente;
  final Map<String, dynamic> triagem;
  final Database database;

  const EncaminhamentoForm({
    super.key,
    required this.paciente,
    required this.triagem,
    required this.database,
  });

  @override
  State<EncaminhamentoForm> createState() => _EncaminhamentoFormState();
}

class _EncaminhamentoFormState extends State<EncaminhamentoForm> {
  final _formKey = GlobalKey<FormState>();

  late final SalaService _salaService;
  late final LeitoService _leitoService;
  late final AlaService _alaService;
  late final MedicoService _medicoService;

  List<Sala> _listaSalas = [];
  List<Leito> _listaLeitos = [];
  List<Ala> _listaAlas = [];
  List<Medico> _listaMedicos = [];
  bool _isLoading = true;

  // Variáveis do Form
  String? _tipoDestino;
  int? _idDestinoSelecionado;
  int? _idMedicoSelecionado;

  // Campos obrigatórios para o prontuário
  String _riscoEvasao = 'BAIXO';
  String _isolamento = 'NAO';

  @override
  void initState() {
    super.initState();
    _salaService = SalaService();
    _leitoService = LeitoService();
    _alaService = AlaService();
    _medicoService = MedicoService(widget.database);
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);
    final salas = await _salaService.listarTodas();
    final leitos = await _leitoService.listarLeitosDisponiveis();
    final alas = await _alaService.listarAlas();
    await _medicoService.carregarMedicos();

    if (mounted) {
      setState(() {
        _listaSalas = salas;
        _listaLeitos = leitos;
        _listaAlas = alas;
        _listaMedicos = _medicoService.medicos;
        _isLoading = false;
      });
    }
  }

  String _getNomeAla(int? idAla) {
    if (idAla == null) return "Sem Ala";
    try {
      return _listaAlas.firstWhere((a) => a.id == idAla).nomeAla ?? "Sem nome";
    } catch (e) {
      return "Ala não encontrada";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text("Encaminhamento Médico",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal)),
                  const Divider(),

                  // 1. DADOS DO PACIENTE
                  _buildSectionTitle("1. Dados do Paciente"),
                  Card(
                    child: ListTile(
                      title: Text(widget.paciente.nome ?? "Sem nome"),
                      subtitle: Text(
                          "CPF: ${widget.paciente.cpf ?? 'N/A'} | Nasc: ${widget.paciente.nascimento ?? 'N/A'}"),
                    ),
                  ),

                  // 2. DADOS DA TRIAGEM
                  _buildSectionTitle("2. Dados da Triagem"),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                          "Risco: ${widget.triagem['risco'] ?? '--'} | Queixa: ${widget.triagem['queixa'] ?? '--'}"),
                    ),
                  ),

                  // 3. AVALIAÇÃO CLÍNICA E DESTINO
                  _buildSectionTitle("3. Avaliação e Destino"),

                  // Novos campos obrigatórios
                  DropdownButtonFormField<String>(
                    initialValue: _riscoEvasao,
                    decoration: const InputDecoration(
                        labelText: "Risco de Evasão *",
                        border: OutlineInputBorder()),
                    items: ['BAIXO', 'MÉDIO', 'ALTO']
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (v) => setState(() => _riscoEvasao = v!),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: _isolamento,
                    decoration: const InputDecoration(
                        labelText: "Isolamento *",
                        border: OutlineInputBorder()),
                    items: ['SIM', 'NAO']
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (v) => setState(() => _isolamento = v!),
                  ),
                  const SizedBox(height: 10),

                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                        labelText: "Médico Responsável *",
                        border: OutlineInputBorder()),
                    items: _listaMedicos
                        .map((m) => DropdownMenuItem(
                            value: m.id, child: Text(m.nome ?? "")))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _idMedicoSelecionado = val),
                    validator: (v) => v == null ? "Selecione o médico" : null,
                  ),

                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                          child: RadioListTile(
                              title: const Text("Sala"),
                              value: 'SALA',
                              groupValue: _tipoDestino,
                              onChanged: (v) => setState(() {
                                    _tipoDestino = v;
                                    _idDestinoSelecionado = null;
                                  }))),
                      Expanded(
                          child: RadioListTile(
                              title: const Text("Leito"),
                              value: 'LEITO',
                              groupValue: _tipoDestino,
                              onChanged: (v) => setState(() {
                                    _tipoDestino = v;
                                    _idDestinoSelecionado = null;
                                  }))),
                    ],
                  ),

                  if (_tipoDestino != null)
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                          labelText: "Selecione o local *",
                          border: OutlineInputBorder()),
                      initialValue: _idDestinoSelecionado,
                      isExpanded: true,
                      items: _tipoDestino == 'SALA'
                          ? _listaSalas
                              .map((s) => DropdownMenuItem<int>(
                                  value: s.id, child: Text(s.nomeSala ?? "")))
                              .toList()
                          : _listaLeitos
                              .map((l) => DropdownMenuItem<int>(
                                  value: l.id,
                                  child: Text(
                                      "Leito ${l.numero} - ${_getNomeAla(l.idAla)}")))
                              .toList(),
                      onChanged: (val) =>
                          setState(() => _idDestinoSelecionado = val),
                      validator: (v) => v == null ? "Obrigatório" : null,
                    ),

                  const SizedBox(height: 25),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50)),
                    onPressed: _finalizarFluxo,
                    child: const Text("Salvar e Enviar para o Médico"),
                  )
                ],
              ),
            ),
    );
  }

  void _finalizarFluxo() async {
    if (_idMedicoSelecionado == null || _idDestinoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Preencha médico e destino!"),
          backgroundColor: Colors.red));
      return;
    }

    try {
      int idProntuario = await widget.database.insert('prontuario', {
        'id_paciente': widget.paciente.id,
        'id_triagem': widget.triagem['id_triagem'],
        'id_medico': _idMedicoSelecionado,
        'id_sala': _tipoDestino == 'SALA' ? _idDestinoSelecionado : null,
        'risco_evasao': _riscoEvasao, // Valor agora garantido
        'isolamento': _isolamento, // Valor agora garantido
        'data_abertura': DateTime.now().toIso8601String(),
        'status_prontuario': 'ATIVO',
      });

      if (_tipoDestino == 'LEITO') {
        await widget.database.insert('internacao', {
          'id_prontuario': idProntuario,
          'id_leito': _idDestinoSelecionado,
          'data_entrada': DateTime.now().toIso8601String(),
        });
        await widget.database.rawUpdate(
            'UPDATE leito SET situacao = ? WHERE id_leito = ?',
            ['OCUPADO', _idDestinoSelecionado]);
      }

      await widget.database.update('triagem', {'internacao': 'SIM'},
          where: 'id_triagem = ?', whereArgs: [widget.triagem['id_triagem']]);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Encaminhado com sucesso!"),
            backgroundColor: Colors.green));
      }
    } catch (e) {
      debugPrint("ERRO: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Erro ao salvar: $e"), backgroundColor: Colors.red));
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blueGrey)),
    );
  }
}
