import 'package:flutter/material.dart';
import '../domain/services/leito_service.dart';
import 'atendimento/evolucao_prontuario_form.dart';

// DASHBOARD
import 'login/tela_login.dart';

class DashboardMedico extends StatefulWidget {
  final dynamic database;

  const DashboardMedico({
    super.key,
    required this.database,
  });

  @override
  State<DashboardMedico> createState() => _DashboardMedicoState();
}

class _DashboardMedicoState extends State<DashboardMedico> {
  final LeitoService _leitoService = LeitoService();
  List<Map<String, dynamic>> _leitos = [];

  @override
  void initState() {
    super.initState();
    _carregarMapa();
  }

  Future<void> _carregarMapa() async {
    final mapa = await _leitoService.buscarMapaLeitos();

    setState(() {
      _leitos = mapa;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(
        title: const Text("Painel do Médico - Mapa de Leitos"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarMapa,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Legenda de Cores
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegenda(Colors.green, "Desocupado"),
                const SizedBox(width: 20),
                _buildLegenda(Colors.red, "Ocupado"),
                const SizedBox(width: 20),
                _buildLegenda(Colors.orange, "Em Higienização"),
              ],
            ),

            const SizedBox(height: 20),

            // Grid de Leitos
            Expanded(
              child: GridView.builder(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: _leitos.length,
                itemBuilder: (context, index) {
                  final leito = _leitos[index];
                  return _buildCardLeito(leito);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.teal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.medical_services,
                  color: Colors.white,
                  size: 50,
                ),
                SizedBox(height: 10),
                Text(
                  'Painel Médico',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // INÍCIO
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Início'),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          // SALAS
          ListTile(
            leading: const Icon(Icons.meeting_room),
            title: const Text('Salas'),
            onTap: () {
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tela de Salas em desenvolvimento'),
                ),
              );
            },
          ),

          const Divider(),

          // SAIR
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: const Text(
              'Sair',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TelaLogin(database: widget.database),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegenda(Color cor, String texto) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: cor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          texto,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCardLeito(Map<String, dynamic> leito) {
    Color corFundo;
    String status = leito['status_leito'] ?? 'VAGO';

    if (status == 'VAGO') {
      corFundo = Colors.green.shade600;
    } else if (status == 'OCUPADO') {
      corFundo = Colors.red.shade600;
    } else {
      corFundo = Colors.orange.shade600;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _interagirComLeito(leito, status),
      child: Card(
        color: corFundo,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.bed,
                color: Colors.white,
                size: 40,
              ),
              const SizedBox(height: 10),
              Text(
                "Leito ${leito['numero_leito']}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (status == 'OCUPADO' &&
                  leito['nome'] != null) ...[
                const SizedBox(height: 5),
                Text(
                  leito['nome']
                      .toString()
                      .split(' ')[0],
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  void _interagirComLeito(
    Map<String, dynamic> leito,
    String status,
  ) async {
    if (status == 'VAGO') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Leito desocupado. Sem paciente no momento.",
          ),
        ),
      );
    } else if (status == 'HIGIENIZACAO') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Leito em higienização! Aguarde a liberação do setor de limpeza.",
          ),
          backgroundColor: Colors.orange,
        ),
      );
    } else if (status == 'OCUPADO') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProntuarioEvolucaoForm(
            dadosLeitoPaciente: leito,
          ),
        ),
      );

      _carregarMapa();
    }
  }
}