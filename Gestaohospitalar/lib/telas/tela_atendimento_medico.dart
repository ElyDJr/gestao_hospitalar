import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart'; 
import '../modelos/modelos_hospitalares.dart';
import '../domain/services/paciente_service.dart'; // 🟢 Seu service real
import '../domain/entities/paciente.dart';        // 🟢 Sua entidade real

class TelaAtendimentoMedico extends StatefulWidget {
  final Database database; 

  const TelaAtendimentoMedico({super.key, required this.database});

  @override
  State<TelaAtendimentoMedico> createState() => _TelaAtendimentoMedicoState();
}

class _TelaAtendimentoMedicoState extends State<TelaAtendimentoMedico> {
  // 🟢 Gerenciamento de dados reais do banco
  late final PacienteService _pacienteService;
  List<Patient> _pacientesReais = [];
  bool _isLoading = true;

  Patient? pacienteSelecionado;

  final evolucaoCtrl = TextEditingController();
  final exameCtrl = TextEditingController(); 
  final medicamentoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pacienteService = PacienteService(widget.database);
    _carregarPacientesDoBanco();
  }

  @override
  void dispose() {
    evolucaoCtrl.dispose();
    exameCtrl.dispose(); 
    medicamentoCtrl.dispose();
    super.dispose();
  }

  // 🟢 Carrega os pacientes salvos pelo enfermeiro
  void _carregarPacientesDoBanco() async {
    try {
      await _pacienteService.carregarPacientes();
      setState(() {
        _pacientesReais = _pacienteService.pacientes.map((p) {
          final map = p.toMap();
          return Patient(
            name: p.nome ?? 'Sem Nome',
            age: map['idade']?.toString() ?? 'Não informada',
            cpf: map['cpf'] ?? 'Não informado',
            bedId: map['leito'] ?? map['id_leito']?.toString() ?? 'Sem Leito',
            insurance: map['convenio'] ?? 'Particular',
            riskLevel: map['classificacaoRisco'] ?? map['risco'] ?? 'Não Urgente',
            observation: map['observacao'] ?? '',
            medication: map['medicacao'] ?? '',
            internado: p.ativo != 0,
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Erro ao carregar dados no atendimento: $e");
      setState(() => _isLoading = false);
    }
  }

  // 🟢 Retorna a cor certa para a bolinha de Manchester (Incluindo o Azul!)
  Color _obterCorManchester(String riskLevel) {
    switch (riskLevel.trim().toLowerCase()) {
      case 'emergência':
      case 'emergencia':
      case 'crítico':
      case 'critico':
      case 'vermelho':
        return Colors.red;
      case 'muito urgente':
      case 'alto':
      case 'laranja':
        return Colors.orange;
      case 'urgente':
      case 'médio':
      case 'medio':
      case 'amarelo':
        return Colors.amber;
      case 'pouco urgente':
      case 'baixo':
      case 'verde':
        return Colors.green;
      case 'não urgente':
      case 'nao urgente':
      case 'azul':
        return Colors.blue; // 🔵 O azul oficial aqui!
      default:
        return Colors.grey;
    }
  }

  void _selecionarPaciente(Patient p) {
    setState(() {
      pacienteSelecionado = p;
    });
  }

  void _salvarAtendimento() {
    if (pacienteSelecionado == null) return;

    setState(() {
      pacienteSelecionado!.evolution += "\n${evolucaoCtrl.text}";
      pacienteSelecionado!.exams += "\n${exameCtrl.text}"; 
      pacienteSelecionado!.medication = medicamentoCtrl.text;

      evolucaoCtrl.clear();
      exameCtrl.clear(); 
      medicamentoCtrl.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Atendimento salvo com sucesso")),
    );
  }

  void _darAlta() {
    if (pacienteSelecionado == null) return;

    setState(() {
      pacienteSelecionado!.discharged = true;
      pacienteSelecionado!.statusAtendimento = "alta";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Paciente recebeu alta médica")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Atendimento Médico"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          // 📋 LISTA DE PACIENTES REAIS
          Container(
            width: 300,
            color: Colors.grey.shade200,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                : _pacientesReais.isEmpty
                    ? const Center(child: Text("Nenhum paciente na fila."))
                    : ListView.builder(
                        itemCount: _pacientesReais.length,
                        itemBuilder: (context, i) {
                          final p = _pacientesReais[i];
                          final corRisco = _obterCorManchester(p.riskLevel);

                          return ListTile(
                            // 🟢 Mostra uma bolinha colorida com a cor de Manchester na esquerda
                            leading: CircleAvatar(
                              radius: 8,
                              backgroundColor: corRisco,
                            ),
                            title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text("Triagem: ${p.riskLevel.toUpperCase()}"),
                            selected: pacienteSelecionado == p,
                            selectedTileColor: Colors.teal.withValues(alpha: 0.1),
                            selectedColor: Colors.teal,
                            onTap: () => _selecionarPaciente(p),
                          );
                        },
                      ),
          ),

          const VerticalDivider(width: 1),

          // 🩺 ÁREA DE ATENDIMENTO
          Expanded(
            child: pacienteSelecionado == null
                ? const Center(
                    child: Text("Selecione um paciente para atender"),
                  )
                : Padding(
                    padding: const EdgeInsets.all(20),
                    child: SingleChildScrollView( 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Paciente: ${pacienteSelecionado!.name}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text("Leito: ${pacienteSelecionado!.bedId}"),
                          
                          // 🟢 Exibe o Risco com a cor de texto correspondente
                          Row(
                            children: [
                              const Text("Triagem: "),
                              Text(
                                pacienteSelecionado!.riskLevel.toUpperCase(),
                                style: TextStyle(
                                  color: _obterCorManchester(pacienteSelecionado!.riskLevel),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          
                          Text("Status: ${pacienteSelecionado!.statusAtendimento}"),
                          Text("Alta: ${pacienteSelecionado!.discharged ? "SIM" : "NÃO"}"),
                          const SizedBox(height: 20),
                          TextField(
                            controller: evolucaoCtrl,
                            decoration: const InputDecoration(
                              labelText: "Evolução médica",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: exameCtrl, // 🟢 Corrigido de 'examenCtrl' para 'exameCtrl'
                            decoration: const InputDecoration(
                              labelText: "Exames solicitados",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: medicamentoCtrl,
                            decoration: const InputDecoration(
                              labelText: "Medicação",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: _salvarAtendimento,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text("Salvar"),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white, 
                                ),
                                onPressed: _darAlta,
                                child: const Text("Dar Alta Médica"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}