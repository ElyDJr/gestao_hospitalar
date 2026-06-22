import 'package:flutter/material.dart';
import '../../domain/entities/leito.dart';
import '../../domain/entities/ala.dart';
import '../../domain/services/leito_service.dart';
import '../../domain/services/ala_service.dart';

class MapaLeitos extends StatefulWidget {
  final LeitoService leitoService;
  final AlaService alaService;

  const MapaLeitos({super.key, required this.leitoService, required this.alaService});

  @override
  State<MapaLeitos> createState() => _MapaLeitosState();
}

class _MapaLeitosState extends State<MapaLeitos> {
  List<Ala> _alas = [];
  List<Leito> _leitos = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final alas = await widget.alaService.listarAlas();
      final leitos = await widget.leitoService.listarLeitosDisponiveis();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Leitos'),
        backgroundColor: Colors.teal,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _alas.isEmpty
              ? const Center(child: Text("Nenhuma ala cadastrada."))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _alas.length,
                  itemBuilder: (context, index) {
                    final ala = _alas[index];
                    // Filtra apenas os leitos desta ala específica
                    final leitosDaAla = _leitos.where((l) => l.idAla == ala.id).toList();

                    return ExpansionTile(
                      leading: const Icon(Icons.bed, color: Colors.teal),
                      title: Text("${ala.nomeAla} - ${ala.andar}", 
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${leitosDaAla.length} leitos encontrados"),
                      children: leitosDaAla.map((leito) {
                        return ListTile(
                          title: Text("Leito: ${leito.numero}"),
                          subtitle: Text("Situação: ${leito.situacao}"),
                          trailing: _getIconeSituacao(leito.situacao),
                        );
                      }).toList(),
                    );
                  },
                ),
    );
  }

  Widget _getIconeSituacao(String? situacao) {
    switch (situacao) {
      case 'OCUPADO': return const Icon(Icons.person, color: Colors.red);
      case 'HIGIENIZACAO': return const Icon(Icons.cleaning_services, color: Colors.orange);
      default: return const Icon(Icons.check_circle, color: Colors.green);
    }
  }
}