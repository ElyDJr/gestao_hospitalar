import 'package:flutter/material.dart';
import '../../domain/services/leito_service.dart';

class ProntuarioEvolucaoForm extends StatefulWidget {
  final Map<String, dynamic> dadosLeitoPaciente;

  const ProntuarioEvolucaoForm({super.key, required this.dadosLeitoPaciente});

  @override
  State<ProntuarioEvolucaoForm> createState() => _ProntuarioEvolucaoFormState();
}

class _ProntuarioEvolucaoFormState extends State<ProntuarioEvolucaoForm> {
  final _evolucaoCtrl = TextEditingController();
  final LeitoService _leitoService = LeitoService();
  
  int _abaSelecionada = 0; 

  // ================= MODIFICAÇÕES AQUI =================
  // Usando um ID inteiro em vez de um Map complexo para evitar o erro do Dropdown
  int? _idExameSelecionado;
  
  final List<Map<String, dynamic>> _listaExamesSolicitados = [];
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
      // Chama o método do seu serviço que busca do banco de dados
      final exames = await _leitoService.listarExamesCatalogo(); 
      
      if (mounted) {
        setState(() {
          _examesDisponiveisNoHospital = exames;
          _carregandoExames = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _carregandoExames = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao carregar catálogo de exames: $e"),
            backgroundColor: Colors.red,
          ),
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
                  _abaSelecionada == 0 
                      ? _buildSecaoEvolucao() 
                      : _buildSecaoExames(),
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
          "Evolução Clínica e Conduta",
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
                      value: _idExameSelecionado,
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
              onPressed: () {
                if (_idExameSelecionado != null) {
                  // Acha o exame completo na lista usando o ID selecionado
                  final exameCompleto = _examesDisponiveisNoHospital.firstWhere(
                    (e) => e['id_exame'] == _idExameSelecionado,
                  );

                  setState(() {
                    _listaExamesSolicitados.insert(0, {
                      'id_exame': exameCompleto['id_exame'],
                      'nome': exameCompleto['nome'],
                      'status': 'SOLICITADO' 
                    });
                    _idExameSelecionado = null; // Reseta após a seleção
                  });
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
            final exame = _listaExamesSolicitados[index];
            final bool concluido = exame['status'] == 'CONCLUIDO';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                leading: Icon(
                  Icons.biotech, 
                  color: concluido ? Colors.green : Colors.orange
                ),
                title: Text(exame['nome'], style: const TextStyle(fontWeight: FontWeight.w600)),
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
                        exame['status'],
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
                              exame['status'] = 'CONCLUIDO';
                            });
                          },
                          child: const Text("Liberar Laudo (Simular)", style: TextStyle(color: Colors.grey)),
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
                          SnackBar(content: Text("Abrindo laudo de: ${exame['nome']}"))
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