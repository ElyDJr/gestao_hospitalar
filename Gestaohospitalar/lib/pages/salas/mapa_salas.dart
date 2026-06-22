import 'package:flutter/material.dart';
import '../../domain/services/sala_service.dart';
import '../../domain/entities/sala.dart';
import '../atendimento/evolucao_prontuario_form.dart';

class MapaSalas extends StatefulWidget {
  const MapaSalas({super.key});
  @override
  State<MapaSalas> createState() => _MapaSalasState();
}

class _MapaSalasState extends State<MapaSalas> {
  final SalaService _salaService = SalaService();
  List<Sala> _salas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarSalas();
  }

  Future<void> _carregarSalas() async {
    final lista = await _salaService.listarTodas();
    setState(() {
      _salas = lista;
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Central de Atendimento - Salas"), backgroundColor: Colors.teal),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, childAspectRatio: 0.8),
              itemCount: _salas.length,
              itemBuilder: (context, i) {
                final sala = _salas[i];
                return _buildCardSala(sala);
              },
            ),
    );
  }

  Widget _buildCardSala(Sala sala) {
    return Card(
      elevation: 4,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.teal.shade50,
            child: Text("Sala ${sala.nomeSala}", style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _salaService.buscarPacientesPorSala(sala.id!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final pacientes = snapshot.data!;
                return ListView.builder(
                  itemCount: pacientes.length,
                  itemBuilder: (ctx, index) {
                    final p = pacientes[index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.person, size: 16),
                      title: Text(p['nome_paciente'], style: const TextStyle(fontSize: 12)),
                      onTap: () {
                        // Ao clicar, abre o prontuário para evoluir
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => ProntuarioEvolucaoForm(dadosLeitoPaciente: p),
                        ));
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}