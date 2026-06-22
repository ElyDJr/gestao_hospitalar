// import 'package:flutter/material.dart';
// import '../../domain/entities/leito.dart';
// import '../../domain/entities/ala.dart';
// import '../../domain/services/leito_service.dart';
// import '../../domain/services/ala_service.dart';

// class MapaLeitos extends StatefulWidget {
//   final LeitoService leitoService;
//   final AlaService alaService;

//   const MapaLeitos({super.key, required this.leitoService, required this.alaService});

//   @override
//   State<MapaLeitos> createState() => _MapaLeitosState();
// }

// class _MapaLeitosState extends State<MapaLeitos> {
//   List<Ala> _alas = [];
//   //List<Leito> _leitos = [];
//   List<Map<String, dynamic>> _leitos = [];
//   bool _carregando = true;

//   // 🟢 Controladores para a barra de pesquisa
//   final TextEditingController _buscaCtrl = TextEditingController();
//   String _termoBusca = '';

//   @override
//   void initState() {
//     super.initState();
//     _carregarDados();
//   }

//   @override
//   void dispose() {
//     _buscaCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _carregarDados() async {
//     try {
//       final alas = await widget.alaService.listarAlas();
//       final leitos = await widget.leitoService.listarLeitosDisponiveis();
//       if (mounted) {
//         setState(() {
//           _alas = alas;
//           _leitos = leitos;
//           _carregando = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) setState(() => _carregando = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Mapa de Leitos'),
//         backgroundColor: Colors.teal,
//       ),
//       body: _carregando
//           ? const Center(child: CircularProgressIndicator())
//           : _alas.isEmpty
//               ? const Center(child: Text("Nenhuma ala cadastrada."))
//               : ListView.builder(
//                   padding: const EdgeInsets.all(8),
//                   itemCount: _alas.length,
//                   itemBuilder: (context, index) {
//                     final ala = _alas[index];
//                     // Filtra apenas os leitos desta ala específica
//                     final leitosDaAla = _leitos.where((l) => l.idAla == ala.id).toList();

//                     return ExpansionTile(
//                       leading: const Icon(Icons.bed, color: Colors.teal),
//                       title: Text("${ala.nomeAla} - ${ala.andar}", 
//                           style: const TextStyle(fontWeight: FontWeight.bold)),
//                       subtitle: Text("${leitosDaAla.length} leitos encontrados"),
//                       children: leitosDaAla.map((leito) {
//                         return ListTile(
//                           title: Text("Leito: ${leito.numero}"),
//                           subtitle: Text("Situação: ${leito.situacao}"),
//                           trailing: _getIconeSituacao(leito.situacao),
//                         );
//                       }).toList(),
//                     );
//                   },
//                 ),
//     );
//   }

//   Widget _getIconeSituacao(String? situacao) {
//     switch (situacao) {
//       case 'OCUPADO': return const Icon(Icons.person, color: Colors.red);
//       case 'HIGIENIZACAO': return const Icon(Icons.cleaning_services, color: Colors.orange);
//       default: return const Icon(Icons.check_circle, color: Colors.green);
//     }
//   }
// }


import 'package:flutter/material.dart';
import '../../domain/services/leito_service.dart';
import 'cadastrar_leito.dart';
import '../../domain/services/ala_service.dart';
import '../../domain/entities/ala.dart';

class MapaLeitos extends StatefulWidget {
  final LeitoService leitoService;
  final AlaService alaService;
  const MapaLeitos({super.key, required this.leitoService, required this.alaService});

  @override
  State<MapaLeitos> createState() => _MapaLeitosState();
}

class _MapaLeitosState extends State<MapaLeitos> {
  final LeitoService _leitoService = LeitoService();
  List<Map<String, dynamic>> _leitos = [];
  List<Ala> _alas = [];
  bool _carregando = true;

  // 🟢 Controladores para a barra de pesquisa
  final TextEditingController _buscaCtrl = TextEditingController();
  String _termoBusca = '';

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
              child: CadastrarLeito(leitoService: _leitoService, alaService: AlaService(),),
            ),
          ),
        );
      },
    );

    if (atualizou == true) _carregarMapa();
  }

  // 🟢 Interação ao clicar no Leito
  void _interagirComLeito(Map<String, dynamic> leito) async {
    String status = leito['status_leito'] ?? 'VAGO';

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

      // Se respondeu SIM, atualiza no banco
      if (confirmou == true) {
        await _leitoService.atualizarStatusLeito(leito['id_leito'], 'VAGO');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Leito liberado para uso!"), backgroundColor: Colors.green),
          );
        }
        _carregarMapa(); // Recarrega os leitos
      }
    } 
    // Opcional: Avisar se clicar no Ocupado
    else if (status == 'OCUPADO') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Leito ocupado por ${leito['nome']?.toString().split(' ')[0] ?? 'um paciente'}."), 
            backgroundColor: Colors.orange
          )
        );
    }
  }

    Widget build(BuildContext context) {
    // 🟢 Aplica o filtro da barra de pesquisa
    final listaFiltrada = _leitos.where((l) {
      final numero = l['numero_leito']?.toString().toLowerCase() ?? '';
      final ala = l['ala']?.toString().toLowerCase() ?? '';
      final andar = l['andar']?.toString().toLowerCase() ?? '';
      final busca = _termoBusca.toLowerCase();
      
      // Busca pelo número, pela ala ou pelo andar
      return numero.contains(busca) || ala.contains(busca) || andar.contains(busca);
    }).toList();

    return Scaffold(
      // 🟢 AppBar com Design de Pesquisa (Idêntico ao Paciente/Médico)
      appBar: AppBar(
        title: const Text("Central de Leitos"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _buscaCtrl,
              onChanged: (valor) => setState(() => _termoBusca = valor),
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: "Buscar leito por número, ala ou andar...",
                fillColor: Colors.white,
                filled: true,
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                suffixIcon: _termoBusca.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _buscaCtrl.clear();
                        setState(() => _termoBusca = '');
                      }
                    )
                  : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCadastro,
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Novo Leito", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Legenda
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegenda(Colors.green, "Vago"),
                const SizedBox(width: 16),
                _buildLegenda(Colors.red, "Ocupado"),
                const SizedBox(width: 16),
                _buildLegenda(Colors.orange, "Limpeza"),
              ],
            ),
            const SizedBox(height: 20),
            
            // Grid de Leitos
            Expanded(
              child: listaFiltrada.isEmpty
                ? const Center(child: Text("Nenhum leito encontrado.", style: TextStyle(fontSize: 16, color: Colors.grey)))
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: listaFiltrada.length,
                    itemBuilder: (context, index) {
                      final leito = listaFiltrada[index];
                      return _buildCardLeito(leito);
                    },
                  ),
            ),
          ],
        ),
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

    if (status == 'VAGO') {
      corFundo = Colors.green.shade600;
    } else if (status == 'OCUPADO') corFundo = Colors.red.shade600;
    else corFundo = Colors.orange.shade600;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _interagirComLeito(leito), // 🟢 Habilita o clique no leito
      child: Card(
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
      ),
    );
  }
}