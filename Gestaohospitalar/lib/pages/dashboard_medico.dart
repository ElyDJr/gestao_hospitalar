// lib/pages/dashboard_medico.dart
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../domain/entities/paciente.dart';
import '../domain/services/paciente_service.dart';
import '../domain/services/triagem_service.dart';

import 'atendimento/registrar_internacao.dart';
import '../telas/tela_mapa_leitos.dart';
import '../telas/tela_atendimento_medico.dart';

import 'login/tela_login.dart';

import 'atendimento/prontuario_paciente.dart';

class DashboardMedico extends StatefulWidget {
  final Database database;

  const DashboardMedico({super.key, required this.database});

  @override
  State<DashboardMedico> createState() => _DashboardMedicoState();
}

class _DashboardMedicoState extends State<DashboardMedico> {
  int _selectedIndex = 0;
  late PacienteService _pacienteService;
  late TriagemService _triagemService;

  List<Map<String, dynamic>> _filaTriagem = [];

  @override
  void initState() {
    super.initState();
    _pacienteService = PacienteService(widget.database);
    _triagemService = TriagemService(widget.database);
    
    _carregarDadosIniciais();
  }

  Future<void> _carregarDadosIniciais() async {
    await _pacienteService.carregarPacientes();
    await _carregarFila();
  }

  Future<void> _carregarFila() async {
    final dados = await _triagemService.buscarFilaTriagem();
    setState(() {
      _filaTriagem = dados;
    });
  }

  void _mostrarTriagem(String nivel, String titulo) {
    final lista = _filaTriagem.where((t) => t['risco'] == nivel).toList();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Fila: $titulo"),
        content: SizedBox(
          width: 400,
          child: lista.isEmpty 
            ? const Padding(padding: EdgeInsets.all(16.0), child: Text("Nenhum paciente aguardando nesta fila."))
            : ListView.builder(
            shrinkWrap: true,
            itemCount: lista.length,
            itemBuilder: (context, i) {
              final item = lista[i];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text("${i + 1}")),
                  title: Text(item['nome'] ?? 'Sem Nome'),
                  subtitle: Text("Pressão: ${item['pressao']} | Queixa: ${item['queixa']}"),
                  onTap: () async {
                    Navigator.pop(context);
                    final p = _pacienteService.pacientes.firstWhere((pac) => pac.id == item['id_paciente']);
                    await abrirDialogoLateral(
                      ProntuarioForm(
                        paciente: p, 
                        triagem: item, 
                        database: widget.database
                      ),
                    );
                    _carregarFila(); 
                    //_abrirProntuarioMedico(pacienteCompleto);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // void _abrirProntuarioMedico(Paciente p) async {
  //   final triagem = await _triagemService.buscarTriagemPorPaciente(p.id!);
  //   final condutaCtrl = TextEditingController(text: triagem?.observacoes ?? '');

  //   if (!mounted) return;

  //   String dataNascimento = 'Não informada';
  //   if (p.nascimento != null) {
  //     dataNascimento = '${p.nascimento!.day.toString().padLeft(2, '0')}/${p.nascimento!.month.toString().padLeft(2, '0')}/${p.nascimento!.year}';
  //   }

  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     builder: (_) => Container(
  //       padding: const EdgeInsets.all(24),
  //       height: MediaQuery.of(context).size.height * 0.85,
  //       child: Column(
  //         children: [
  //           Text("Prontuário: ${p.nome}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
  //           const Divider(),
  //           Text("CPF: ${p.cpf ?? 'Não informado'}  |  Nascimento: $dataNascimento", style: const TextStyle(fontSize: 16)),
  //           const SizedBox(height: 20),
            
  //           if (triagem != null)
  //             Card(
  //               child: Padding(
  //                 padding: const EdgeInsets.all(16),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text("Queixa Principal: ${triagem.queixa ?? 'Nenhuma informada'}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  //                     const Divider(),
  //                     Text(
  //                       "Sinais Vitais:\nPA: ${triagem.pressao ?? '--'}  |  Temp: ${triagem.temperatura ?? '--'}°C  |  Sat O2: ${triagem.saturacao ?? '--'}%",
  //                       style: const TextStyle(fontSize: 15, height: 1.5),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
              
  //           const SizedBox(height: 20),
  //           Expanded(
  //             child: TextFormField(
  //               controller: condutaCtrl,
  //               maxLines: 6,
  //               decoration: const InputDecoration(labelText: "Conduta Médica / Evolução", border: OutlineInputBorder()),
  //             ),
  //           ),
  //           Row(
  //             children: [
  //               Expanded(
  //                 child: ElevatedButton(
  //                   style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
  //                   // ─── LÓGICA DO BOTÃO DAR ALTA ───
  //                   onPressed: () async {
  //                     if (triagem != null) {
  //                       // 1. Criar um seletor de médico para a alta
  //                       final medicoSelecionado = await _selecionarMedico(context);
  //                       final String isolamento = 'NAO';
  //                       if (medicoSelecionado == null) return; // Cancela se não selecionar médico

  //                       try {
  //                         // 2. Criar o registro no PRONTUÁRIO
  //                         await widget.database.insert('prontuario', {
  //                           'id_paciente': p.id,
  //                           'id_triagem': triagem.id, // ID da triagem capturado
  //                           'id_medico': medicoSelecionado, // ID do médico selecionado
  //                           'risco_evasao': 'N/A', // Valor padrão para cumprir NOT NULL
  //                           'isolamento': isolamento, // Usando a variável local
  //                           'evolucao': condutaCtrl.text, // Evolução atualizada
  //                           'data_abertura': DateTime.now().toIso8601String(),
  //                           'status_prontuario': 'ARQUIVADO', // Alta = Arquivado
  //                         });

  //                         // 3. Atualizar triagem para encerrar
  //                         final triagemAtualizada = triagem.copyWith(
  //                           observacoes: condutaCtrl.text,
  //                           internacao: 'ALTA'
  //                         );
  //                         await _triagemService.salvarTriagem(triagemAtualizada);

  //                         if (mounted) {
  //                           Navigator.pop(context);
  //                           await _carregarFila();
  //                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Alta registrada com sucesso!")));
  //                         }
  //                       } catch (e) {
  //                         debugPrint("Erro ao registrar prontuário: $e");
  //                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
  //                       }
  //                     }
  //                   },
  //                   child: const Text("Dar Alta", style: TextStyle(color: Colors.white)),
  //                 ),
  //               ),
  //               const SizedBox(width: 10),
  //               Expanded(
  //                 child: ElevatedButton(
  //                   style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
  //                   onPressed: () async {
  //                     if (triagem != null) {
  //                       // 1. Médicos marcam apenas como SOLICITADO
  //                       final triagemAtualizada = triagem.copyWith(
  //                         observacoes: condutaCtrl.text,
  //                         internacao: 'SOLICITADO' // Status novo para o Admin ver
  //                       );
                        
  //                       await _triagemService.salvarTriagem(triagemAtualizada);
                        
  //                       if (mounted) {
  //                         Navigator.pop(context); // Fecha o prontuário
  //                         _carregarFila(); // Atualiza a dashboard do médico imediatamente
  //                         ScaffoldMessenger.of(context).showSnackBar(
  //                           const SnackBar(content: Text("Internação solicitada! Aguardando Admin."), backgroundColor: Colors.orange)
  //                         );
  //                       }
  //                     }
  //                   },
  //                   child: const Text("Solicitar Internação", style: TextStyle(color: Colors.white)),
  //                 ),
  //               ),
  //             ],
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }

  void _mostrarFilaInternacaoAdmin() {
  final lista = _filaTriagem.where((t) => t['internacao'] == 'SOLICITADO').toList();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Pacientes Aguardando Alocação de Leito"),
        content: SizedBox(
          width: 400,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: lista.length,
            itemBuilder: (context, i) {
              final item = lista[i];
              return Card(
                child: ListTile(
                  title: Text(item['nome'] ?? 'Sem Nome'),
                  subtitle: Text("Solicitado por: Médico"),
                  trailing: const Icon(Icons.bed, color: Colors.purple),
                  onTap: () async {
                    Navigator.pop(context);
                    // Busca o paciente completo para abrir o formulário
                    final p = _pacienteService.pacientes.firstWhere((pac) => pac.id == item['id_paciente']);
                    
                    // ABRE O FORMULÁRIO DE INTERNAÇÃO (O mesmo que já construímos)
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegistrarInternacao(paciente: p, pacienteService: _pacienteService),
                      ),
                    );
                    _carregarFila(); // Atualiza a Dashboard após o Admin cadastrar
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  Future<void> abrirDialogoLateral(Widget content) async {
    await showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) => Align(
        alignment: Alignment.centerRight,
        child: Material(
          child: SizedBox(
            width: 500, // Largura fixa do painel lateral
            child: content,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Portal do Médico - MONGE"),
        backgroundColor: Colors.blueGrey, // Cor diferente para o médico saber onde está
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout), // Ícone de porta/saída
            tooltip: 'Sair do Sistema',
            onPressed: () {
              // Redireciona para a tela de login limpando a memória de telas anteriores
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => TelaLogin(database: widget.database),
                ),
                (route) => false, // Garante que o usuário não consiga "voltar" sem logar
              );
            },
          ),
        const SizedBox(width: 16), // Dá um espaço elegante até a borda da tela
          ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) {
              setState(() => _selectedIndex = i);
            },
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text("Início")),
              NavigationRailDestination(icon: Icon(Icons.healing), label: Text("Atendimento")),
              NavigationRailDestination(icon: Icon(Icons.bed), label: Text("Leitos")),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _getPage(_selectedIndex)),
        ],
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0: return _dashboardMedico();
      case 1: return TelaAtendimentoMedico(database: widget.database); // Atendimentos agendados
      case 2: return const TelaMapaLeitos(); // Mapa de Leitos
      default: return _dashboardMedico();
    }
  }

  Widget _dashboardMedico() {
    int emergencia = _filaTriagem.where((t) => t['risco'] == "VERMELHO").length;
    int muitoUrgente = _filaTriagem.where((t) => t['risco'] == "LARANJA").length;
    int urgente = _filaTriagem.where((t) => t['risco'] == "AMARELO").length;
    int poucoUrgente = _filaTriagem.where((t) => t['risco'] == "VERDE").length;
    int naoUrgente = _filaTriagem.where((t) => t['risco'] == "AZUL").length;

    //card para solicitação de internação
    int solicitados = _filaTriagem.where((t) => t['internacao'] == 'SOLICITADO').length;


    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Pacientes Aguardando Atendimento", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            children: [
              GestureDetector(onTap: () => _mostrarTriagem("VERMELHO", "Emergência"), child: _card("🔴 Emergência", emergencia, Colors.red)),
              GestureDetector(onTap: () => _mostrarTriagem("LARANJA", "Muito Urgente"), child: _card("🟠 Muito Urgente", muitoUrgente, Colors.orange)),
              GestureDetector(onTap: () => _mostrarTriagem("AMARELO", "Urgente"), child: _card("🟡 Urgente", urgente, Colors.yellow.shade700)),
              GestureDetector(onTap: () => _mostrarTriagem("VERDE", "Pouco Urgente"), child: _card("🟢 Pouco Urgente", poucoUrgente, Colors.green)),
              GestureDetector(onTap: () => _mostrarTriagem("AZUL", "Não Urgente"), child: _card("🔵 Não Urgente", naoUrgente, Colors.blue)),
              GestureDetector(onTap: () => _mostrarFilaInternacaoAdmin(), child: _card("Aguardando Leito", solicitados, Colors.purple)),

            ],
          ),
        ],
      ),
    );
  }

  Widget _card(String title, int value, Color color) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: color)),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text("$value", style: TextStyle(fontSize: 26, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<int?> _selecionarMedico(BuildContext context) async {
  final medicos = await widget.database.query('medico');
  int? idSelecionado;

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Selecione o Médico"),
      content: SizedBox(
        width: 300,
        child: DropdownButtonFormField<int>(
          decoration: const InputDecoration(labelText: "Médico responsável"),
          items: medicos.map((m) => DropdownMenuItem(
            value: m['id_medico'] as int,
            child: Text(m['nome']?.toString() ?? 'Sem nome'),
          )).toList(),
          onChanged: (val) => idSelecionado = val,
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
      ],
    ),
  );
  return idSelecionado;
  }
}