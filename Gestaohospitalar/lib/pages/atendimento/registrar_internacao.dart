import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // <--- Importação necessária
import '../../domain/entities/paciente.dart';
import '../../domain/entities/leito.dart';
import '../../domain/entities/internacao.dart';
import '../../domain/services/leito_service.dart';
import '../../domain/services/internacao_service.dart';
import '../../domain/services/paciente_service.dart';
import '../../data/resources/database_provider.dart';

class RegistrarInternacao extends StatefulWidget {
  final Paciente paciente;
  final PacienteService pacienteService;

  const RegistrarInternacao({
    super.key,
    required this.paciente,
    required this.pacienteService,
  });

  @override
  State<RegistrarInternacao> createState() => _RegistrarInternacaoState();
}

class _RegistrarInternacaoState extends State<RegistrarInternacao> {
  final LeitoService _leitoService = LeitoService();
  final InternacaoService _internacaoService = InternacaoService();
  
  // Formatador de data para exibir ao usuário (dd/MM/yyyy)
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

  Leito? _leitoSelecionado;
  bool _necessitaIsolamento = false;
  bool _salvando = false;

  // Busca o prontuário ativo do paciente no banco
  Future<int?> _buscarIdProntuarioAtivo(int idPaciente) async {
    final db = await DatabaseProvider.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'prontuario',
      where: 'id_paciente = ? AND status_prontuario = ?',
      whereArgs: [idPaciente, 'ATIVO'],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return maps.first['id_prontuario'] as int;
    }
    return null;
  }

  Future<void> _salvarInternacao() async {
    if (_leitoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um leito!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _salvando = true);

    try {
      final idProntuario = await _buscarIdProntuarioAtivo(widget.paciente.id!);
      
      if (idProntuario == null) {
        throw Exception("Nenhum prontuário ATIVO encontrado para este paciente.");
      }

      // Salva no formato ISO 8601 (padrão SQLite)
      final novaInternacao = Internacao(
        idProntuario: idProntuario,
        idLeito: _leitoSelecionado!.id!,
        //dataEntrada: DateTime.now().toIso8601String(),
        isolamento: _necessitaIsolamento ? 'SIM' : 'NAO',
        statusInternacao: 'ATIVA',
      );

      await _internacaoService.registrarInternacao(novaInternacao);
      //await _leitoService.atualizarStatusLeito(_leitoSelecionado!.id!, 'OCUPADO');

      final pacienteAtualizado = widget.paciente.copyWith(historicoClinico: 'Internado');
      await widget.pacienteService.salvarPaciente(pacienteAtualizado);
      await widget.pacienteService.carregarPacientes();

      if (!mounted) return;

      Navigator.of(context).popUntil((route) => route.isFirst);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Internação realizada com sucesso!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao internar: $e'), backgroundColor: Colors.red),
      );
      setState(() => _salvando = false);
    }
  }

 @override
  Widget build(BuildContext context) {
    // 1. Declare a variável UMA ÚNICA VEZ
    String dataNascFormatada = "N/A";

    // 2. Agora, faça a lógica para dar valor a ela
    if (widget.paciente.nascimento != null) {
      dataNascFormatada = _dateFormatter.format(widget.paciente.nascimento!);
    }
    
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Internação')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Paciente: ${widget.paciente.nome}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Nascimento: $dataNascFormatada'), // A variável agora contém o valor formatado
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),


            FutureBuilder<List<Leito>>(
              future: _leitoService.listarLeitosDisponiveis(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return DropdownButtonFormField<Leito>(
                    decoration: const InputDecoration(labelText: 'Selecione o Leito', border: OutlineInputBorder()),
                    items: snapshot.data!.map((leito) {
                      return DropdownMenuItem(
                        value: leito,
                        child: Text('Leito ${leito.numero} - ${leito.ala}'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _leitoSelecionado = val),
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
            
            SwitchListTile(
              title: const Text('Isolamento?'),
              value: _necessitaIsolamento,
              onChanged: (val) => setState(() => _necessitaIsolamento = val),
            ),
            
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _salvando ? null : _salvarInternacao,
              child: Text(_salvando ? 'Salvando...' : 'Confirmar Internação'),
            ),
          ],
        ),
      ),
    );
  }
}