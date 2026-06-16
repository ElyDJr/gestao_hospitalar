import 'package:flutter/material.dart';
import '../domain/services/leito_service.dart';
import 'atendimento/evolucao_prontuario_form.dart';
import 'login/tela_login.dart';

class DashboardMedico extends StatefulWidget {
  final dynamic database;
  const DashboardMedico({super.key, required this.database});

  @override
  State<DashboardMedico> createState() => _DashboardMedicoState();
}

class _DashboardMedicoState extends State<DashboardMedico> {
  int _selectedIndex = 0;
  final LeitoService _leitoService = LeitoService();
  List<Map<String, dynamic>> _leitos = [];

  @override
  void initState() {
    super.initState();
    _carregarMapa();
  }

  Future<void> _carregarMapa() async {
  final mapa = await _leitoService.buscarMapaLeitos();
  print("DEBUG: Total de linhas retornadas pelo SQL: ${mapa.length}");
  for (var m in mapa) {
    print("DEBUG: Leito ${m['numero_leito']} - Paciente: ${m['nome']}");
  }
  if (mounted) {
    setState(() {
      _leitos = mapa;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel do Médico"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => TelaLogin(database: widget.database)),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
                // A MÁGICA: Sempre que clicar em "Salas", ele força a atualização dos dados
                if (_selectedIndex == 1) {
                  _carregarMapa();
                }
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text("Início"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.meeting_room),
                label: Text("Salas"),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _selectedIndex == 0
                ? const Center(child: Text("Bem-vindo ao Painel do Médico."))
                : _buildMapaLeitos(),
          ),
        ],
      ),
    );
  }

  Widget _buildMapaLeitos() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Legenda
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _buildLegenda(Colors.green.shade600, "Desocupado"),
            const SizedBox(width: 20),
            _buildLegenda(Colors.red.shade600, "Ocupado"),
            const SizedBox(width: 20),
            _buildLegenda(Colors.orange.shade600, "Em Higienização"),
          ]),
          const SizedBox(height: 20),
          // Grid de Leitos
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: _leitos.length,
              itemBuilder: (context, i) => _buildCardLeito(_leitos[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegenda(Color cor, String texto) => Row(children: [
    Container(width: 20, height: 20, decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
    const SizedBox(width: 8),
    Text(texto, style: const TextStyle(fontWeight: FontWeight.bold))
  ]);

  Widget _buildCardLeito(Map<String, dynamic> leito) {
    String status = leito['status_leito'] ?? 'VAGO';
    Color corFundo = status == 'VAGO' 
        ? Colors.green.shade600 
        : (status == 'OCUPADO' ? Colors.red.shade600 : Colors.orange.shade600);

    return InkWell(
      onTap: () async {
        if (status == 'OCUPADO') {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProntuarioEvolucaoForm(dadosLeitoPaciente: leito)),
          );
          // Atualiza ao voltar do prontuário
          _carregarMapa();
        }
      },
      child: Card(
        color: corFundo,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bed, color: Colors.white, size: 40),
            Text("Leito ${leito['numero_leito']}", 
                 style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}