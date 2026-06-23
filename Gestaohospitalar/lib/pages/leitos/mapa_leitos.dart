import 'package:flutter/material.dart';
import '../../domain/entities/ala.dart';
import '../../domain/services/leito_service.dart';
import '../../domain/services/ala_service.dart';
import 'cadastrar_leito.dart'; // 🟢 Importação da tela

// 🟢 Classe principal corrigida (havia sido apagada acidentalmente)
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

  // 🟢 Controladores para a barra de pesquisa
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
      // Mudança principal: Busca todos os leitos com seus respectivos status e pacientes (igual ao Dashboard)
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

  // 🟢 ADICIONADO: Função para abrir o painel lateral de Novo Leito
  void _abrirCadastroLeito() async {
    final atualizou = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        alignment: Alignment.centerRight, // Abre colado na direita
        insetPadding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.35, // Largura do painel
          child: CadastrarLeito(
            leitoService: widget.leitoService,
            alaService: widget.alaService,
          ),
        ),
      ),
    );

    // Se salvou com sucesso, recarrega o mapa
    if (atualizou == true) {
      setState(() {
        _carregando = true;
      });
      _carregarDados();
    }
  }

  // 🟢 Interação ao clicar no Leito atualizada
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
              onPressed: () => Navigator.pop(context, false), // Responde NÃO
              child: const Text("NÃO", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(context, true), // Responde SIM
              child: const Text("SIM"),
            ),
          ],
        ),
      );

      // 🟢 Se respondeu SIM, atualiza no banco e recarrega a tela
      if (confirmou == true) {
        await widget.leitoService.atualizarStatusLeito(leito['id_leito'], 'VAGO');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Leito liberado para uso!"), backgroundColor: Colors.green),
          );
        }
        _carregarDados(); // Recarrega as alas e leitos atualizando as cores
      }
    } 
    // 🟢 Feedback ao clicar no leito Ocupado
    else if (status == 'OCUPADO') {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa Geral de Leitos'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      // 🟢 ADICIONADO: Botão Flutuante no canto inferior direito
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCadastroLeito,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Novo Leito"),
      ),
      body: Column(
        children: [
          // Legenda de Cores
          Padding(
            padding: const EdgeInsets.all(12.0),
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
                : _alas.isEmpty
                    ? const Center(child: Text("Nenhuma ala cadastrada."))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _alas.length,
                        itemBuilder: (context, index) {
                          final ala = _alas[index];
                          
                          // Filtra os leitos que pertencem a esta ala específica
                          final leitosDaAla = _leitos
                              .where((l) => l['ala'] == ala.nomeAla)
                              .toList();

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ExpansionTile(
                              initiallyExpanded: true, // Já vem expandido para facilitar a visão geral
                              leading: const Icon(Icons.meeting_room, color: Colors.teal),
                              title: Text("${ala.nomeAla} - ${ala.andar}", 
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text("${leitosDaAla.length} leitos cadastrados"),
                              children: [
                                if (leitosDaAla.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text("Nenhum leito cadastrado nesta ala.", 
                                      style: TextStyle(color: Colors.grey)),
                                  )
                                else
                                  // GridView que organiza os cards estilo dashboard
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(12.0),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 5, // 3 cards por linha, bom para celular
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 1.02,
                                    ),
                                    itemCount: leitosDaAla.length,
                                    itemBuilder: (context, idx) {
                                      return _buildCardLeito(leitosDaAla[idx]);
                                    },
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

  // Componente da Legenda
  Widget _buildLegenda(Color cor, String texto) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(texto, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  // Componente do Card igual ao Dashboard do Médico
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

    // 🟢 Captura a ação de clique
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
            mainAxisSize: MainAxisSize.min, 
            children: [
              const Icon(Icons.bed, color: Colors.white, size: 30), 
              const SizedBox(height: 6),
              Text(
                "Leito ${leito['numero_leito'] ?? ''}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14, 
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
              ] else ...[
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white70, 
                      fontSize: 11, 
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
}