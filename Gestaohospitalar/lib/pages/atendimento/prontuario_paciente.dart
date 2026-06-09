import 'package:flutter/material.dart';
import '../../domain/entities/paciente.dart';
import '../../domain/entities/leito.dart';
import '../../domain/entities/internacao.dart';
import '../../domain/services/leito_service.dart';
import '../../domain/services/internacao_service.dart';
import '../../domain/services/paciente_service.dart';
import 'registrar_internacao.dart';

class ProntuarioPaciente extends StatefulWidget {
  final Paciente paciente;
  final PacienteService pacienteService;
  
  const ProntuarioPaciente({
    super.key, 
    required this.paciente,
    required this.pacienteService, // 🟢 NOVA LINHA
  });

  @override
  State<ProntuarioPaciente> createState() => _ProntuarioPacienteState();
}

class _ProntuarioPacienteState extends State<ProntuarioPaciente> {
  final LeitoService _leitoService = LeitoService();
  final InternacaoService _internacaoService = InternacaoService();
  //final PacienteService _pacienteService = PacienteService(GenericRepositoryImpl());

  // 🟢 A MÁGICA ACONTECE AQUI: O Dialog de Internação
  void _abrirDialogInternacao() {
    Leito? leitoSelecionado;
    bool necessitaIsolamento = false;

    showDialog(
      context: context,
      builder: (context) {
        // StatefulBuilder é necessário para atualizar o dropdown e o checkbox dentro do Dialog
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Internar ${widget.paciente.nome}'),
              content: FutureBuilder<List<Leito>>(
                future: _leitoService.listarLeitosDisponiveis(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("Nenhum leito disponível no momento.", style: TextStyle(color: Colors.red));
                  }

                  final leitos = snapshot.data!;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // RF06: Seleção do Leito
                      DropdownButtonFormField<Leito>(
                        decoration: const InputDecoration(labelText: 'Selecione o Leito'),
                        initialValue: leitoSelecionado,
                        items: leitos.map((leito) {
                          return DropdownMenuItem(
                            value: leito,
                            child: Text('Leito ${leito.numero} - Ala: ${leito.ala}'),
                          );
                        }).toList(),
                        onChanged: (Leito? novoLeito) {
                          setStateDialog(() {
                            leitoSelecionado = novoLeito;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // RF07: Necessita Isolamento?
                      CheckboxListTile(
                        title: const Text("Necessita de Isolamento?"),
                        value: necessitaIsolamento,
                        onChanged: (bool? valor) {
                          setStateDialog(() {
                            necessitaIsolamento = valor ?? false;
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: leitoSelecionado == null
                      ? null // Desabilita o botão se não escolher leito
                      : () => _confirmarInternacao(leitoSelecionado!.id!, necessitaIsolamento),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text('Confirmar Internação', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmarInternacao(int idLeito, bool isolamento) async {
    try {
      // 1. Aqui você salvaria o Prontuario primeiro para pegar o ID dele.
      // Supondo que você já tem o ID do prontuário (vou usar 1 como exemplo didático)
      int idProntuario = 1; 

      // 2. Criar o objeto de Internação
      final novaInternacao = Internacao(
        idProntuario: idProntuario,
        idLeito: idLeito,
        dataEntrada: DateTime.now(), // Passa DateTime puro, o toMap cuida do resto
        statusInternacao: 'ATIVA',
        isolamento: isolamento ? 'SIM' : 'NAO', // Converte booleano para SQL
      );

      // 3. Salvar no banco
      await _internacaoService.registrarInternacao(novaInternacao);

      // 4. RN14: Atualizar o status do leito para OCUPADO
      await _leitoService.atualizarStatusLeito(idLeito, 'OCUPADO');

      // 5. Tirar o paciente da fila da Dashboard (limpando a urgência/historicoClinico)
      final pacienteAtualizado = widget.paciente.copyWith(historicoClinico: 'Internado');

      await widget.pacienteService.salvarPaciente(pacienteAtualizado);
      // Força a atualização global dos pacientes para a Dashboard sumir com o card
      await widget.pacienteService.carregarPacientes();

      if (mounted) {
        Navigator.pop(context); // Fecha o Dialog
        Navigator.pop(context); // Fecha o Prontuário e volta pra Dashboard
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paciente internado com sucesso!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (!mounted) return; // 🟢 CORREÇÃO: Aqui no catch também!
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao internar: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('Prontuário - ${widget.paciente.nome}')),
      body: const Center(
        // Aqui vai o layout do seu prontuário (campos de queixa, prescrição, etc)
        child: Text("Conteúdo do Prontuário aqui"),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              // 🟢 NAVEGAÇÃO PARA A NOVA TELA
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegistrarInternacao(
                      paciente: widget.paciente,
                      pacienteService: widget.pacienteService,
                    ),
                  ),
                );
              }, 
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Encaminhar p/ Internação'),
            ),
          ],
        ),
      ),
    );
  }
}

  // Continua abaixo...