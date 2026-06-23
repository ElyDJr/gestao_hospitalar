import 'package:flutter/material.dart';
import '../../domain/entities/ala.dart';
import '../../domain/services/leito_service.dart';
import '../../domain/services/ala_service.dart';
import 'cadastrar_leito.dart';

class MapaLeitos extends StatefulWidget {
  final LeitoService leitoService;
  final AlaService alaService;

  const MapaLeitos({super.key, required this.leitoService, required this.alaService});

  @override
  State<MapaLeitos> createState() => _MapaLeitosState();
}

class _MapaLeitosState extends State<MapaLeitos> {
  List<Ala> _alas = [];
  List<Map<String, dynamic>> _leitos = []; 
  bool _carregando = true;

  final TextEditingController _buscaCtrl = TextEditingController();
  String _termoBusca = '';

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final alas = await widget.alaService.listarAlas();
      final leitos = await widget.leitoService.buscarMapaLeitos();
      
      if (mounted) {
        setState(() {
          _alas = alas;
          _leitos = leitos;
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _abrirCadastroLeito() async {
    final atualizou = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        alignment: Alignment.centerRight,
        insetPadding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.35,
          child: CadastrarLeito(
            leitoService: widget.leitoService,
            alaService: widget.alaService,
          ),
        ),
      ),
    );

    if (atualizou == true) {
      setState(() { _carregando = true; });
      _carregarDados();
    }
  }

  void _interagirComLeito(Map<String, dynamic> leito) async {
    String status = leito['status_leito']?.toString().toUpperCase() ?? 'VAGO';

    if (status == 'HIGIENIZACAO') {
      final confirmou = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Leito em Higienização"),
          content: Text("O leito ${leito['numero_leito']} já foi higienizado e está pronto para uso?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("NÃO", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("SIM"),
            ),
          ],
        ),
      );

      if (confirmou == true) {
        await widget.leitoService.atualizarStatusLeito(leito['id_leito'], 'VAGO');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Leito liberado para uso!"), backgroundColor: Colors.green),
          );
        }
        _carregarDados();
      }
    } else if (status == 'OCUPADO') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Leito ocupado por ${leito['nome']?.toString().split(' ')[0] ?? 'um paciente'}."), 
          backgroundColor: Colors.orange
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lógica para filtrar as alas com base no termo digitado
    final alasFiltradas = _alas.where((ala) => 
        ala.nomeAla.toLowerCase().contains(_termoBusca.toLowerCase())
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa Geral de Leitos'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCadastroLeito,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Novo Leito"),
      ),
      body: Column(
        children: [
          // Campo de busca
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _buscaCtrl,
              onChanged: (value) => setState(() => _termoBusca = value),
              decoration: InputDecoration(
                hintText: "Buscar por ala...",
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
          
          // Legenda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegenda(Colors.green.shade600, "Desocupado"),
                const SizedBox(width: 12),
                _buildLegenda(Colors.red.shade600, "Ocupado"),
                const SizedBox(width: 12),
                _buildLegenda(Colors.orange.shade600, "Higienização"),
              ],
            ),
          ),
          
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : alasFiltradas.isEmpty
                    ? const Center(child: Text("Nenhuma ala encontrada."))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: alasFiltradas.length,
                        itemBuilder: (context, index) {
                          final ala = alasFiltradas[index];
                          final leitosDaAla = _leitos.where((l) => l['ala'] == ala.nomeAla).toList();

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ExpansionTile(
                              initiallyExpanded: true,
                              leading: const Icon(Icons.bed, color: Colors.teal),
                              title: Text("${ala.nomeAla} - ${ala.andar}", style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text("${leitosDaAla.length} leitos cadastrados"),
                              children: [
                                if (leitosDaAla.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text("Nenhum leito cadastrado nesta ala.", style: TextStyle(color: Colors.grey)),
                                  )
                                else
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(12.0),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 5,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 1.02,
                                    ),
                                    itemCount: leitosDaAla.length,
                                    itemBuilder: (context, idx) => _buildCardLeito(leitosDaAla[idx]),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegenda(Color cor, String texto) {
    return Row(
      children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(texto, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  Widget _buildCardLeito(Map<String, dynamic> leito) {
    Color corFundo;
    String status = leito['status_leito']?.toString().toUpperCase() ?? 'VAGO';

    if (status == 'VAGO' || status == 'DESOCUPADO') corFundo = Colors.green.shade600;
    else if (status == 'OCUPADO') corFundo = Colors.red.shade600;
    else corFundo = Colors.orange.shade600;

    String primeiroNome = (leito['nome']?.toString().trim().split(' ') ?? [''])[0];

    return GestureDetector(
      onTap: () => _interagirComLeito(leito),
      child: Card(
        color: corFundo,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bed, color: Colors.white, size: 30),
              const SizedBox(height: 6),
              Text("Leito ${leito['numero_leito'] ?? ''}", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Flexible(child: Text(status == 'OCUPADO' ? primeiroNome : status, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis, maxLines: 1)),
            ],
          ),
        ),
      ),
    );
  }
}