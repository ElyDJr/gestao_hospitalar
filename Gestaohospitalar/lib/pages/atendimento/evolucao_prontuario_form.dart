import 'package:flutter/material.dart';
import '../../domain/services/leito_service.dart';
import '../../domain/services/exame_service.dart';
// Import da nova tela de prescrição
import 'prescricao_prontuario_form.dart';
// Adicionado para podermos salvar a alteração dos sinais vitais na Triagem
import '../../data/resources/database_provider.dart';

import '../../domain/services/faturamento_service.dart';

class ProntuarioEvolucaoForm extends StatefulWidget {
  final Map<String, dynamic> dadosLeitoPaciente;

  const ProntuarioEvolucaoForm({super.key, required this.dadosLeitoPaciente});

  @override
  State<ProntuarioEvolucaoForm> createState() => _ProntuarioEvolucaoFormState();
}

class _ProntuarioEvolucaoFormState extends State<ProntuarioEvolucaoForm> {
  // Controllers para Evolução e Sinais Vitais
  final _evolucaoCtrl = TextEditingController();
  final _pressaoCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();
  final _satCtrl = TextEditingController();
  final _fcCtrl = TextEditingController(); // Frequência Cardíaca
  final _queixaCtrl = TextEditingController();

  final LeitoService _leitoService = LeitoService();
  final ExameService _exameService = ExameService();

  int _abaSelecionada = 0;
  int? _idExameSelecionado;

  List<Map<String, dynamic>> _listaExamesSolicitados = [];
  List<Map<String, dynamic>> _examesDisponiveisNoHospital = [];
  bool _carregandoExames = true;

  @override
  void initState() {
    super.initState();
    final d = widget.dadosLeitoPaciente;

    // PREENCHE A EVOLUÇÃO
    _evolucaoCtrl.text = d['evolucao'] ?? '';

    // PREENCHE OS SINAIS VITAIS BUSCANDO DE FORMA SEGURA DA TRIAGEM
    _pressaoCtrl.text =
        d['pressao_arterial']?.toString() ?? d['pressao']?.toString() ?? '';
    _tempCtrl.text = d['temperatura']?.toString() ?? '';
    _satCtrl.text = d['saturacao']?.toString() ?? '';
    _fcCtrl.text = d['frequencia_cardiaca']?.toString() ?? '';
    _queixaCtrl.text =
        d['queixa_principal']?.toString() ?? d['queixa']?.toString() ?? '';

    _carregarExamesDoBanco();
  }

  Future<void> _carregarExamesDoBanco() async {
    try {
      final idProntuario = widget.dadosLeitoPaciente['id_prontuario'] ??
          widget.dadosLeitoPaciente['id'];

      final exames = await _leitoService.listarExamesCatalogo();
      final historico =
          await _exameService.buscarExamesPorProntuario(idProntuario);

      if (mounted) {
        setState(() {
          _examesDisponiveisNoHospital = exames;
          _listaExamesSolicitados = historico;
          _carregandoExames = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _carregandoExames = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Erro ao carregar exames: $e"),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _evolucaoCtrl.dispose();
    _pressaoCtrl.dispose();
    _tempCtrl.dispose();
    _satCtrl.dispose();
    _fcCtrl.dispose();
    _queixaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.dadosLeitoPaciente;
    final bool isLeito = d['numero_leito'] != null;

    String localAtendimento = isLeito
      ? "Leito ${d['numero_leito']} - Prontuário Médico"
      : "Sala ${d['nome_sala'] ?? ''} - Prontuário Médico";

    // Lógica inteligente para o título: Se tem leito, mostra o Leito. Senão, mostra a Sala.
    // String localAtendimento = "";
    // if (d['numero_leito'] != null) {
    //   localAtendimento = "Leito ${d['numero_leito']} - Prontuário Médico";
    // } else if (d['nome_sala'] != null) {
    //   localAtendimento = "Sala ${d['nome_sala']} - Prontuário Médico";
    // } else {
    //   localAtendimento = "Atendimento - Prontuário Médico";
    // }

    return Scaffold(
      appBar: AppBar(
        title: Text(localAtendimento),
        backgroundColor: Colors.teal
            .shade700, // Ajustei a cor para Teal para ficar padronizado, mas pode voltar para Red se preferir
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            tooltip: "Dar Alta/Liberar",
            onPressed: () => _confirmarAlta(isLeito),
          ),
        ],
        elevation: 2,
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _abaSelecionada,
            onDestinationSelected: (int index) {
              setState(() {
                _abaSelecionada = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.grey.shade100,
            selectedIconTheme:
                IconThemeData(color: Colors.teal.shade700, size: 28),
            unselectedIconTheme: const IconThemeData(color: Colors.grey),
            selectedLabelTextStyle: TextStyle(
                color: Colors.teal.shade700, fontWeight: FontWeight.bold),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.description_outlined),
                selectedIcon: Icon(Icons.description),
                label: Text('Evolução'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.science_outlined),
                selectedIcon: Icon(Icons.science),
                label: Text('Exames'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.medication_outlined),
                selectedIcon: Icon(Icons.medication),
                label: Text('Prescrição'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // CARD 1: Informações Pessoais do Paciente
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(Icons.person,
                          size: 40, color: Colors.blue),
                      title: Text(
                        "Paciente: ${d['nome_paciente'] ?? d['nome'] ?? 'Não informado'}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "CPF: ${d['cpf'] ?? 'N/A'}\nData de Admissão: ${d['data_abertura']?.split('T')[0] ?? 'N/A'}",
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // CARD 2: Informações Clínicas Fixas
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Informações Clínicas Importantes",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const Divider(),
                          Text(
                              "Alergias: ${d['alergias'] ?? 'Nenhuma relatada'}",
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                              "Risco de Evasão: ${d['risco_evasao'] ?? 'N/A'} | Isolamento: ${d['isolamento'] ?? 'N/A'}"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // EXIBIÇÃO DINÂMICA DAS ABAS
                  _abaSelecionada == 0
                      ? _buildSecaoEvolucao()
                      : _abaSelecionada == 1
                          ? _buildSecaoExames()
                          : PrescricaoProntuarioForm(
                              dadosLeitoPaciente: widget.dadosLeitoPaciente),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ABA 1: EVOLUÇÃO E SINAIS VITAIS
  Widget _buildSecaoEvolucao() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sinais vitais editáveis
        const Text(
          "Sinais Vitais e Sintomas (Editáveis)",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        const Text(
            "Dados aferidos na triagem. Altere-os se houve nova medição no atendimento.",
            style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: TextFormField(
                    controller: _pressaoCtrl,
                    decoration: const InputDecoration(
                        labelText: "Pressão (PA)",
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                        filled: true))),
            const SizedBox(width: 10),
            Expanded(
                child: TextFormField(
                    controller: _tempCtrl,
                    decoration: const InputDecoration(
                        labelText: "Temp (°C)",
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                        filled: true))),
            const SizedBox(width: 10),
            Expanded(
                child: TextFormField(
                    controller: _satCtrl,
                    decoration: const InputDecoration(
                        labelText: "SpO2 (%)",
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                        filled: true))),
            const SizedBox(width: 10),
            Expanded(
                child: TextFormField(
                    controller: _fcCtrl,
                    decoration: const InputDecoration(
                        labelText: "FC (bpm)",
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                        filled: true))),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _queixaCtrl,
          maxLines: 2,
          decoration: const InputDecoration(
              labelText: "Queixa Principal",
              border: OutlineInputBorder(),
              fillColor: Colors.white,
              filled: true),
        ),

        const SizedBox(height: 24),

        // Campo de texto principal da Evolução
        const Text(
          "Evolução Clínica e Conduta",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _evolucaoCtrl,
          maxLines: 12,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: "Digite a evolução médica e conduta de hoje...",
            fillColor: Colors.white,
            filled: true,
          ),
        ),
        const SizedBox(height: 24),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 55),
            backgroundColor: Colors.teal,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _salvarEvolucao,
          child: const Text(
            "Salvar Evolução",
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  // ABA 2: EXAMES (Seu código não foi alterado)
  Widget _buildSecaoExames() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Solicitar Novo Exame",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _carregandoExames
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : DropdownButtonFormField<int>(
                      initialValue: _idExameSelecionado,
                      hint: const Text(
                          "Selecione um exame cadastrado no hospital..."),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      items: _examesDisponiveisNoHospital.isEmpty
                          ? [
                              const DropdownMenuItem<int>(
                                  value: null,
                                  child:
                                      Text("Nenhum exame encontrado no banco"))
                            ]
                          : _examesDisponiveisNoHospital.map((exame) {
                              return DropdownMenuItem<int>(
                                value: exame['id_exame'] as int,
                                child: Text(exame['nome'] ?? 'Sem Nome'),
                              );
                            }).toList(),
                      onChanged: (novoValor) {
                        setState(() {
                          _idExameSelecionado = novoValor;
                        });
                      },
                    ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(150, 55),
                backgroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                if (_idExameSelecionado != null) {
                  try {
                    final idProntuario =
                        widget.dadosLeitoPaciente['id_prontuario'] ??
                            widget.dadosLeitoPaciente['id'];
                    final idMedico =
                        widget.dadosLeitoPaciente['id_medico'] ?? 1;

                    await _exameService.solicitarNovoExame(
                      idProntuario: idProntuario,
                      idExame: _idExameSelecionado!,
                      idMedico: idMedico,
                    );

                    final historicoAtualizado = await _exameService
                        .buscarExamesPorProntuario(idProntuario);

                    setState(() {
                      _listaExamesSolicitados = historicoAtualizado;
                      _idExameSelecionado = null;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            "Exame solicitado e salvo no banco com sucesso!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Erro ao salvar no banco: $e"),
                          backgroundColor: Colors.red),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          "Selecione um exame da lista antes de solicitar."),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Solicitar",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        const SizedBox(height: 30),
        const Text(
          "Histórico de Exames Solicitados",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
        ),
        const Divider(),
        const SizedBox(height: 10),
        if (_listaExamesSolicitados.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Nenhum exame solicitado para este paciente nesta consulta.",
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _listaExamesSolicitados.length,
          itemBuilder: (context, index) {
            final examen = _listaExamesSolicitados[index];
            final bool concluido = examen['status'] == 'CONCLUIDO';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                leading: Icon(Icons.biotech,
                    color: concluido ? Colors.green : Colors.orange),
                title: Text(examen['nome'],
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Row(
                  children: [
                    const Text("Status: "),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: concluido
                              ? Colors.green.shade100
                              : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(4)),
                      child: Text(
                        examen['status'],
                        style: TextStyle(
                            color: concluido
                                ? Colors.green.shade900
                                : Colors.orange.shade900,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                trailing: !concluido
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                examen['status'] = 'CONCLUIDO';
                              });
                            },
                            child: const Text("Liberar Laudo",
                                style: TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.orange),
                          ),
                        ],
                      )
                    : TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text("Abrindo laudo de: ${examen['nome']}")));
                        },
                        icon: const Icon(Icons.visibility, color: Colors.blue),
                        label: const Text("Ver Resultado",
                            style: TextStyle(color: Colors.blue)),
                      ),
              ),
            );
          },
        ),
      ],
    );
  }

  // MÉTODO PARA SALVAR EVOLUÇÃO E ATUALIZAR SINAIS VITAIS
  void _salvarEvolucao() async {
    try {
      final idProntuario = widget.dadosLeitoPaciente['id_prontuario'] ??
          widget.dadosLeitoPaciente['id'];

      // 1. Atualiza o texto da evolução no prontuário
      await _leitoService.atualizarEvolucaoProntuario(
        idProntuario,
        _evolucaoCtrl.text,
      );

      // 2. Atualiza a tabela triagem com os sinais vitais alterados
      final idTriagem = widget.dadosLeitoPaciente['id_triagem'];
      if (idTriagem != null) {
        final db = await DatabaseProvider.instance.database;
        await db.update(
            'triagem',
            {
              'pressao': _pressaoCtrl.text,
              'temperatura': _tempCtrl.text,
              'saturacao': _satCtrl.text,
              'frequencia_cardiaca': _fcCtrl.text,
              'queixa': _queixaCtrl.text,
            },
            where: 'id_triagem = ?',
            whereArgs: [idTriagem]);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Evolução salva com sucesso!"),
            backgroundColor: Colors.green));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red));
    }
  }

  // void _confirmarAlta(bool isLeito) {
  //   showDialog(
  //       context: context,
  //       builder: (ctx) => AlertDialog(
  //             title: const Text("Confirmar Alta/Liberação"),
  //             content: Text(isLeito
  //                 ? "O paciente terá alta, o leito irá para higienização e os custos serão calculados."
  //                 : "O atendimento será encerrado e a consulta enviada ao faturamento."),
  //             actions: [
  //               TextButton(
  //                   onPressed: () => Navigator.pop(ctx),
  //                   child: const Text("Cancelar")),
  //               ElevatedButton(
  //                 onPressed: () async {
  //                   Navigator.pop(ctx);
  //                   // Chama a lógica de cálculo e alta
  //                   await _processarFinalizacao(isLeito);
  //                 },
  //                 child: const Text("Confirmar"),
  //               ),
  //             ],
  //           ));
  // }

  // O MÉTODO DEFINITIVO DE ALTA
  Future<void> _processarFinalizacao(bool isLeito) async {
    // 1. Salva evolução
    final idProntuario = widget.dadosLeitoPaciente['id_prontuario'] ?? widget.dadosLeitoPaciente['id'];
    await _leitoService.atualizarEvolucaoProntuario(idProntuario, _evolucaoCtrl.text);
    
    // 2. Processa alta e faturamento via Transação
    final db = await DatabaseProvider.instance.database;
    await FaturamentoService(db).processarAltaEGerarFaturamento(
      idProntuario: idProntuario,
      idInternacao: isLeito ? widget.dadosLeitoPaciente['id_internacao'] : null,
      idSala: !isLeito ? widget.dadosLeitoPaciente['id_sala'] : null,
      idLeito: isLeito ? widget.dadosLeitoPaciente['id_leito'] : null,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Alta concluída com sucesso!")));
    }
  }

  void _confirmarAlta(bool isLeito) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmar Alta/Liberação"),
        content: const Text("Deseja finalizar o atendimento e gerar faturamento?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _processarFinalizacao(isLeito);
            },
            child: const Text("Confirmar"),
          ),
        ],
      )
    );
  }
}
