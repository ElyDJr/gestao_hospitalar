import 'package:flutter/material.dart';
import '../../domain/services/sala_service.dart';
import 'cadastrar_salas.dart';

class MapaSalas extends StatefulWidget {
  const MapaSalas({super.key});

  @override
  State<MapaSalas> createState() => _MapaSalasState();
}

class _MapaSalasState extends State<MapaSalas> {
  // 🟢 CORREÇÃO 1: Inicialização direta no escopo global da classe. 
  // Sem "late", sem risco de "LateInitializationError" e sem precisar de _inicializarService.
  final SalaService _salaService = SalaService();

  bool _carregandoBanco = true;
  List<Map<String, dynamic>> _salas = [];

  final TextEditingController _buscaCtrl = TextEditingController();
  String _termoBusca = '';

  @override
  void initState() {
    super.initState();
    _carregarMapaSalas(); // 🟢 CORREÇÃO 2: Chama o carregamento direto de forma segura
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregarMapaSalas() async {
    try {
      // 🟢 COMENTADO TEMPORARIAMENTE: Ignora o banco de dados vazio por enquanto
      // final mapa = await _salaService.buscarMapaSalas();

      // 🟢 INJETADO DIRETO: Dados fictícios para os cards aparecerem na tela imediatamente
      final mapa = [
        {'id_sala': 1, 'numero_sala': '101', 'ala': 'Ala Norte', 'andar': '1º Andar', 'status_sala': 'DISPONIVEL'},
        {'id_sala': 2, 'numero_sala': '102', 'ala': 'Ala Sul', 'andar': '1º Andar', 'status_sala': 'OCUPADO', 'nome': 'Carlos Silva'},
        {'id_sala': 3, 'numero_sala': '203', 'ala': 'UTI Geral', 'andar': '2º Andar', 'status_sala': 'HIGIENIZACAO'},
        {'id_sala': 4, 'numero_sala': '204', 'ala': 'Pediatria', 'andar': '2º Andar', 'status_sala': 'DISPONIVEL'},
      ];

      if (mounted) {
        setState(() {
          _salas = mapa;
          _carregandoBanco = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _carregandoBanco = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao carregar mapa de salas: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
              child: CadastrarSalas(
                salaService: _salaService,
              ),
            ),
          ),
        );
      },
    );

    if (atualizou == true) {
      _carregarMapaSalas();
    }
  }

  void _interagirComSala(Map<String, dynamic> sala) async {
    String status = sala['status_sala']?.toString().toUpperCase() ?? 'DISPONIVEL';

    if (status == 'HIGIENIZACAO' || status == 'LIMPEZA') {
      final confirmou = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Sala em Higienização"),
          content: Text(
            "A sala ${sala['numero_sala'] ?? ''} já foi higienizada e está pronta para uso?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                "NÃO",
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("SIM"),
            ),
          ],
        ),
      );

      if (confirmou == true) {
        final idRaw = sala['id_sala'];
        final int? idSala = idRaw is int ? idRaw : int.tryParse(idRaw.toString());

        if (idSala != null) {
          await _salaService.atualizarStatusSala(idSala, 'DISPONIVEL');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Sala liberada para uso!"),
                backgroundColor: Colors.green,
              ),
            );
          }

          _carregarMapaSalas();
        }
      }
    } else if (status == 'OCUPADO') {
      final nome = (sala['nome'] ?? '').toString().trim();
      final primeiroNome = nome.isNotEmpty ? nome.split(' ')[0] : 'um paciente';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Sala ocupada por $primeiroNome."),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final listaFiltrada = _salas.where((s) {
      final numero = (s['numero_sala'] ?? '').toString().toLowerCase();
      final ala = (s['ala'] ?? '').toString().toLowerCase();
      final andar = (s['andar'] ?? '').toString().toLowerCase();
      final busca = _termoBusca.toLowerCase();

      return numero.contains(busca) || ala.contains(busca) || andar.contains(busca);
    }).toList();

    if (_carregandoBanco) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.teal)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Central de Salas"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _buscaCtrl,
              onChanged: (valor) => setState(() => _termoBusca = valor),
              decoration: InputDecoration(
                hintText: "Buscar sala por número, ala ou andar...",
                fillColor: Colors.white,
                filled: true,
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                suffixIcon: _termoBusca.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _buscaCtrl.clear();
                          setState(() => _termoBusca = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCadastro,
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Nova Sala"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegenda(Colors.green, "Disponível"),
                const SizedBox(width: 16),
                _buildLegenda(Colors.red, "Ocupada"),
                const SizedBox(width: 16),
                _buildLegenda(Colors.orange, "Limpeza"),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: listaFiltrada.isEmpty
                  ? const Center(
                      child: Text("Nenhuma sala encontrada."),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: listaFiltrada.length,
                      itemBuilder: (context, index) {
                        final sala = listaFiltrada[index];
                        return _buildCardSala(sala);
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
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: cor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(texto),
      ],
    );
  }

  Widget _buildCardSala(Map<String, dynamic> sala) {
    Color corFundo;
    String status = sala['status_sala']?.toString().toUpperCase() ?? 'DISPONIVEL';

    if (status == 'DISPONIVEL') {
      corFundo = Colors.green.shade600;
    } else if (status == 'OCUPADO') {
      corFundo = Colors.red.shade600;
    } else {
      corFundo = Colors.orange.shade600;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _interagirComSala(sala),
      child: Card(
        color: corFundo,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.meeting_room, color: Colors.white, size: 30),
            const SizedBox(height: 6),
            Text(
              "Sala ${sala['numero_sala'] ?? ''}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "${sala['ala'] ?? ''} - ${sala['andar'] ?? ''}",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}