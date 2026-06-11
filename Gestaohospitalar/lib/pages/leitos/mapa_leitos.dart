import 'package:flutter/material.dart';
import '../../domain/services/leito_service.dart';
import 'cadastrar_leito.dart';

class MapaLeitos extends StatefulWidget {
  const MapaLeitos({super.key});

  @override
  State<MapaLeitos> createState() => _MapaLeitosState();
}

class _MapaLeitosState extends State<MapaLeitos> {
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

  // Lógica da abertura lateral (a mesma usada na dashboard)
  Future<void> _abrirCadastro() async {
    final atualizou = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Cadastro",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            elevation: 10,
            color: Colors.white,
            child: SizedBox(
              width: 450,
              height: double.infinity,
              child: CadastrarLeito(leitoService: _leitoService),
            ),
          ),
        );
      },
    );

    if (atualizou == true) _carregarMapa();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Cabeçalho com Legenda e Botões
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildLegenda(Colors.green, "Vago"),
                  const SizedBox(width: 16),
                  _buildLegenda(Colors.red, "Ocupado"),
                  const SizedBox(width: 16),
                  _buildLegenda(Colors.orange, "Limpeza"),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.teal),
                    tooltip: "Atualizar",
                    onPressed: _carregarMapa,
                  ),
                  ElevatedButton.icon(
                    onPressed: _abrirCadastro,
                    icon: const Icon(Icons.add),
                    label: const Text("Cadastrar Leito"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          
          // Grid de Leitos
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1, 
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
    );
  }

  Widget _buildLegenda(Color cor, String texto) {
    return Row(
      children: [
        Container(width: 16, height: 16, decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(texto, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCardLeito(Map<String, dynamic> leito) {
    Color corFundo;
    String status = leito['status_leito'] ?? 'VAGO';

    if (status == 'VAGO') corFundo = Colors.green.shade600;
    else if (status == 'OCUPADO') corFundo = Colors.red.shade600;
    else corFundo = Colors.orange.shade600;

    return Card(
      color: corFundo,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bed, color: Colors.white, size: 30),
            const SizedBox(height: 6),
            Text(
              "Leito ${leito['numero_leito']}",
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              "${leito['ala'] ?? ''} - ${leito['andar'] ?? ''}",
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            if (status == 'OCUPADO' && leito['nome'] != null) ...[
              const SizedBox(height: 4),
              Text(
                leito['nome'].toString().split(' ')[0], 
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ]
          ],
        ),
      ),
    );
  }
}