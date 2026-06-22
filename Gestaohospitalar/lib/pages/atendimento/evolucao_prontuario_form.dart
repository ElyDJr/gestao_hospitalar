import 'package:flutter/material.dart';
import '../../domain/services/leito_service.dart';
import '../../domain/services/exame_service.dart';
// 🟢 PASSO 1: Import da nova tela de prescrição
import 'prescricao_prontuario_form.dart';

class ProntuarioEvolucaoForm extends StatefulWidget {
  final Map<String, dynamic> dadosLeitoPaciente;

  const ProntuarioEvolucaoForm({super.key, required this.dadosLeitoPaciente});

  @override
  State<ProntuarioEvolucaoForm> createState() => _ProntuarioEvolucaoFormState();
}

class _ProntuarioEvolucaoFormState extends State<ProntuarioEvolucaoForm> {
  final _evolucaoCtrl = TextEditingController();
  final LeitoService _leitoService = LeitoService();

  // 1. Adicione o ExameService aqui:
  final ExameService _exameService = ExameService();

  int _abaSelecionada = 0; 
  int? _idExameSelecionado;
  
  //final List<Map<String, dynamic>> _listaExamesSolicitados = [];
  List<Map<String, dynamic>> _listaExamesSolicitados = [];
  List<Map<String, dynamic>> _examesDisponiveisNoHospital = [];
  bool _carregandoExames = true; // Para mostrar um indicador de loading no dropdown
  // =====================================================

  @override
  void initState() {
    super.initState();
    _evolucaoCtrl.text = widget.dadosLeitoPaciente['evolucao'] ?? '';
    _carregarExamesDoBanco(); // Chamando a função ao iniciar a tela
  }

  // ================= NOVA FUNÇÃO PARA BUSCAR DADOS =================
  Future<void> _carregarExamesDoBanco() async {
    try {
      final idProntuario = widget.dadosLeitoPaciente['id_prontuario'];
      
      // Busca os exames do catálogo
      final exames = await _leitoService.listarExamesCatalogo(); 
      // Busca o histórico do paciente no banco de dados
      final historico = await _exameService.buscarExamesPorProntuario(idProntuario);
      
      if (mounted) {
        setState(() {
          _examesDisponiveisNoHospital = exames;
          _listaExamesSolicitados = historico; // Atualiza a tela com o banco!
          _carregandoExames = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _carregandoExames = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao carregar exames: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }
  // =================================================================

  @override
  void dispose() {
    _evolucaoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.dadosLeitoPaciente;

    return Scaffold(
      appBar: AppBar(
        title: Text("Leito ${d['numero_leito']} - Prontuário Médico"),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
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
            selectedIconTheme: IconThemeData(color: Colors.teal.shade700, size: 28),
            unselectedIconTheme: const IconThemeData(color: Colors.grey),
            selectedLabelTextStyle: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.bold),
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
              // 🟢 PASSO 2: Adicionado o ícone da prescrição abaixo de exames
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
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(Icons.person, size: 40, color: Colors.blue),
                      title: Text(
                        "Paciente: ${d['nome']}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "CPF: ${d['cpf']}\nData de Admissão: ${d['data_abertura']?.split('T')[0] ?? 'N/A'}",
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Sinais Vitais (Entrada)",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const Divider(),
                          Text(
                            "Pressão: ${d['pressao']} | Temp: ${d['temperatura']}°C | Sat: ${d['saturacao']}% | FC: ${d['frequencia_cardiaca']}bpm",
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Queixa Principal: ${d['queixa']}",
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                          Text("Alergias: ${d['alergias'] ?? 'Nenhuma relatada'}"),
                          Text("Risco de Evasão: ${d['risco_evasao']} | Isolamento: ${d['isolamento']}"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 🟢 PASSO 3: Lógica atualizada para renderizar a nova aba quando _abaSelecionada for igual a 2
                  _abaSelecionada == 0 
                      ? _buildSecaoEvolucao() 
                      : _abaSelecionada == 1
                          ? _buildSecaoExames()
                          : PrescricaoProntuarioForm(dadosLeitoPaciente: widget.dadosLeitoPaciente),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecaoEvolucao() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Evolução Clinical e Conduta",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _evolucaoCtrl,
          maxLines: 12,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: "Digite a evolução médica, prescrições e conduta de hoje...",
            fillColor: Colors.white,
            filled: true,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 55),
            backgroundColor: Colors.teal,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _salvarEvolucao,
          child: const Text(
            "Salvar Evolução",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Widget _buildSecaoExames() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Solicitar Novo Exame",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // ================= DROPDOWN MODIFICADO PARA USAR <int> =================
            Expanded(
              child: _carregandoExames
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : DropdownButtonFormField<int>( // Alterado para <int>
                      initialValue: _idExameSelecionado,
                      hint: const Text("Selecione um exame cadastrado no hospital..."),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      items: _examesDisponiveisNoHospital.isEmpty 
                        ? [
                            const DropdownMenuItem<int>(
                              value: null, 
                              child: Text("Nenhum exame encontrado no banco")
                            )
                          ]
                        : _examesDisponiveisNoHospital.map((exame) {
                            return DropdownMenuItem<int>( // Alterado para <int>
                              value: exame['id_exame'] as int, // Pega apenas o ID
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
            // =========================================================================
            const SizedBox(width: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(150, 55),
                backgroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                if (_idExameSelecionado != null) {
                  try {
                    final idProntuario = widget.dadosLeitoPaciente['id_prontuario'];
                    final idMedico = widget.dadosLeitoPaciente['id_medico'] ?? 1; // ID do médico (1 como fallback)

                    // 1. CHAMA O BANCO DE DADOS PARA SALVAR (usando o método que arrumamos)
                    await _exameService.solicitarNovoExame(
                      idProntuario: idProntuario,
                      idExame: _idExameSelecionado!,
                      idMedico: idMedico,
                    );

                    // 2. BUSCA A LISTA ATUALIZADA DO BANCO
                    final historicoAtualizado = await _exameService.buscarExamesPorProntuario(idProntuario);

                    // 3. ATUALIZA A TELA
                    setState(() {
                      _listaExamesSolicitados = historicoAtualizado;
                      _idExameSelecionado = null; // Reseta o dropdown
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Exame solicitado e salvo no banco com sucesso!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Erro ao salvar no banco: $e"), backgroundColor: Colors.red),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Selecione um exame da lista antes de solicitar."),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Solicitar", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        const SizedBox(height: 30),
        const Text(
          "Histórico de Exames Solicitados",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                leading: Icon(
                  Icons.biotech, 
                  color: concluido ? Colors.green : Colors.orange
                ),
                title: Text(examen['nome'], style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Row(
                  children: [
                    const Text("Status: "),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: concluido ? Colors.green.shade100 : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(4)
                      ),
                      child: Text(
                        examen['status'],
                        style: TextStyle(
                          color: concluido ? Colors.green.shade900 : Colors.orange.shade900,
                          fontSize: 12,
                          fontWeight: FontWeight.bold
                        ),
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
                          child: const Text("Liberar Laudo", style: TextStyle(color: Colors.grey)),
                        ),
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange),
                        ),
                      ],
                    )
                  : TextButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Abrindo laudo de: ${examen['nome']}"))
                        );
                      },
                      icon: const Icon(Icons.visibility, color: Colors.blue),
                      label: const Text("Ver Resultado", style: TextStyle(color: Colors.blue)),
                    ),
              ),
            );
          },
        ),
      ],
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