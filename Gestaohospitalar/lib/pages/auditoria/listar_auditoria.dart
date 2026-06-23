import 'package:flutter/material.dart';
import '../../domain/services/historico_service.dart';
import '../../data/resources/database_provider.dart'; // Importe seu provider para pegar o db

class ListarAuditoriaPage extends StatefulWidget {
  const ListarAuditoriaPage({super.key});

  @override
  State<ListarAuditoriaPage> createState() => _ListarAuditoriaPageState();
}

class _ListarAuditoriaPageState extends State<ListarAuditoriaPage> {
  late HistoricoService _service;
  bool _isLoading = true;
  List<Map<String, dynamic>> _historico = [];

  @override
  void initState() {
    super.initState();
    _iniciarServico();
  }

  Future<void> _iniciarServico() async {
    // 1. Pega a instância do Provider
    // 2. Aguarda o banco de dados estar pronto (await)
    final db = await DatabaseProvider.instance.database; 
    
    setState(() {
      _service = HistoricoService(db);
      _isLoading = false;
    });
    
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final dados = await _service.listarHistoricoUnificado();
    setState(() => _historico = dados);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auditoria e Logs')),
      body: ListView.builder(
        itemCount: _historico.length,
        itemBuilder: (context, index) {
          final item = _historico[index];
          final isClinico = item['tipo'] == 'CLINICO';

          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isClinico ? Colors.blue : Colors.green,
                child: Icon(isClinico ? Icons.local_hospital : Icons.attach_money, color: Colors.white),
              ),
              title: Text(item['detalhes'] ?? 'Sem descrição'),
              subtitle: Text(
                '${item['tipo']} | Por: ${item['usuario']} | ${item['data']}'
              ),
            ),
          );
        },
      ),
    );
  }
}