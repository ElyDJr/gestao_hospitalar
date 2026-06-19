import 'package:flutter/material.dart';
import '../domain/services/leito_service.dart';
import 'atendimento/evolucao_prontuario_form.dart';
import 'salas/mapa_salas.dart';
import '../domain/services/sala_service.dart';

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
  List<Map<String, dynamic>> _leitosFiltrados = [];
  List<Map<String, dynamic>> _todosLeitosDoBanco = [];
  
  // Controle da Busca
  final TextEditingController _buscaCtrl = TextEditingController();
  String _termoBusca = '';
  
  final List<String> _categorias = [
    "Emergência",
    "UTI",
    "Pediatria",
    "Cardiologia",
    "Maternidade",
    "Clínica Médica"
  ];
  
  String _categoriaSelecionada = "Emergência";

  @override
  void initState() {
    super.initState();
    _carregarMapa();
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregarMapa() async {
    final mapa = await _leitoService.buscarMapaLeitos();
    
    // Debug para você ver no terminal se os dados estão chegando
    debugPrint("DEBUG: Total de leitos no banco: ${mapa.length}");
    if (mapa.isNotEmpty) {
      debugPrint("DEBUG: Exemplo de um leito: ${mapa.first}");
    }

    if (mounted) {
      setState(() {
        _todosLeitosDoBanco = mapa;
        _filtrarLeitos(_categoriaSelecionada);
      });
    }
  }

  void _filtrarLeitos(String categoria) {
    setState(() {
      _categoriaSelecionada = categoria;
      
      // Filtramos a lista real que veio do banco (_todosLeitosDoBanco)
      _leitosFiltrados = _todosLeitosDoBanco.where((leito) {
        
        // Verifica se a ala do leito corresponde à categoria (ala) atual (ignorando maiúsculas/minúsculas)
        final bool naCategoria = (leito['ala']?.toString().toLowerCase() ?? "emergência") == categoria.toLowerCase();
        
        // Lógica de Busca Global
        if (_termoBusca.isNotEmpty) {
          final numLeito = leito['numero_leito']?.toString().toLowerCase() ?? '';
          final nomePac = leito['nome']?.toString().toLowerCase() ?? '';
          final busca = _termoBusca.toLowerCase();
          
          return numLeito.contains(busca) || nomePac.contains(busca);
        }

        return naCategoria;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            const Text(
              "Ala Médica",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 24),
            // Campo de busca posicionado na barra superior ao lado do título
            Expanded(
              child: SizedBox(
                height: 40,
                child: TextField(
                  controller: _buscaCtrl,
                  style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Buscar Leito ou Paciente...',
                    hintStyle: const TextStyle(color: Color.fromARGB(153, 0, 0, 0)),
                    prefixIcon: const Icon(
                     Icons.search,
                      color: Color.fromARGB(255, 0, 150, 136),
                      size: 20),
                    suffixIcon: _buscaCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Color.fromARGB(255, 0, 150, 136), size: 20),
                            onPressed: () {
                              _buscaCtrl.clear();
                              setState(() {
                                _termoBusca = '';
                                _filtrarLeitos(_categoriaSelecionada);
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color.fromARGB(255, 253, 252, 252),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (valor) {
                    _termoBusca = valor;
                    _filtrarLeitos(_categoriaSelecionada);
                  },
                ),
              ),
            ),
          ],
        ),
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
            // Botões de Categorias lado a lado ocupando a mesma linha horizontal
            Row(
              children: _categorias.map((categoria) {
                final bool isSelected = _categoriaSelecionada == categoria;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected ? Colors.teal : Colors.grey.shade300,
                          foregroundColor: isSelected ? Colors.white : Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          _buscaCtrl.clear();
                          _termoBusca = '';
                          _filtrarLeitos(categoria);
                        },
                        child: Text(
                          categoria,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

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
              child: _leitosFiltrados.isEmpty
                  ? const Center(
                      child: Text(
                        "Nenhum leito encontrado para esta busca.",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.95,
                      ),
                      itemCount: _leitosFiltrados.length,
                      itemBuilder: (context, index) {
                        final leito = _leitosFiltrados[index];
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
            onTap: () async {
              Navigator.pop(context); 

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MapaSalas(),
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
    String status = leito['status_leito']?.toString().toUpperCase() ?? 'VAGO';

    if (status == 'VAGO' || status == 'DESOCUPADO') {
      corFundo = Colors.green.shade600;
    } else if (status == 'OCUPADO') {
      corFundo = Colors.red.shade600;
    } else {
      corFundo = Colors.orange.shade600;
    }

    String primeiroNome = '';
    final nomeBruto = leito['nome']?.toString().trim() ?? '';
    if (nomeBruto.isNotEmpty) {
      final partes = nomeBruto.split(' ');
      if (partes.isNotEmpty) {
        primeiroNome = partes[0];
      }
    }

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _interagirComLeito(leito, status),
      child: Card(
        color: corFundo,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, 
            children: [
              const Icon(Icons.bed, color: Colors.white, size: 32), 
              const SizedBox(height: 6),
              Text(
                "Leito ${leito['numero_leito'] ?? ''}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15, 
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
              if (status == 'OCUPADO' && primeiroNome.isNotEmpty) ...[
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    primeiroNome,
                    style: const TextStyle(
                      color: Colors.white70, 
                      fontSize: 12, 
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
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
    // Redireciona a categoria ativa para a ala correspondente do leito clicado antes de abrir a ação
    if (leito['ala'] != null) {
      setState(() {
        _categoriaSelecionada = leito['ala'];
        _buscaCtrl.clear();
        _termoBusca = '';
      });
    }

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