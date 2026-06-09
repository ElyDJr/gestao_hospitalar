import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../modelos/modelos_hospitalares.dart';
import '../domain/services/paciente_service.dart'; 
import '../domain/entities/paciente.dart';        

class TelaMedico extends StatefulWidget {
  final Database database;
  final Doctor doctor;

  const TelaMedico({super.key, required this.database, required this.doctor});

  @override
  State<TelaMedico> createState() => _TelaMedicoState();
}

class _TelaMedicoState extends State<TelaMedico> {
  late final PacienteService _pacienteService;
  List<Patient> _pacientesSobCuidados = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pacienteService = PacienteService(widget.database);
    _carregarPacientesDoEnfermeiro();
  }

  void _carregarPacientesDoEnfermeiro() async {
    try {
      await _pacienteService.carregarPacientes();

      setState(() {
        _pacientesSobCuidados = _pacienteService.pacientes.map((p) {
          final map = p.toMap(); 

          return Patient(
            name: p.nome ?? 'Sem Nome',
            age: map['idade']?.toString() ?? 'Não informada',
            cpf: map['cpf'] ?? 'Não informado',
            bedId: map['leito'] ?? map['id_leito']?.toString() ?? 'Sem Leito',
            insurance: map['convenio'] ?? 'Particular',
            // O riskLevel vai receber o texto que o enfermeiro digitou/selecionou no formulário
            riskLevel: map['classificacaoRisco'] ?? map['risco'] ?? 'Não Urgente',
            observation: map['observacao'] ?? 'Nenhuma observação clínica gravada.',
            medication: map['medicacao'] ?? '',
            internado: p.ativo != 0,
            isolamento: map['isolamento'] == 1 || map['isolamento'] == true,
            tipoIsolamento: map['tipoIsolamento'] ?? map['tipo_isolamento'] ?? 'Nenhum',
          );
        }).toList();
        
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Erro ao carregar pacientes na tela do médico: $e");
      setState(() => _isLoading = false);
    }
  }

  // 🟢 FUNÇÃO AUXILIAR: Mapeia o texto do banco para as cores oficiais de Manchester
  Color _obterCorManchester(String riskLevel) {
    switch (riskLevel.trim().toLowerCase()) {
      case 'emergência':
      case 'emergencia':
      case 'crítico':
      case 'critico':
      case 'vermelho':
        return Colors.red.shade700;
      case 'muito urgente':
      case 'alto':
      case 'laranja':
        return Colors.orange.shade800;
      case 'urgente':
      case 'médio':
      case 'medio':
      case 'amarelo':
        return Colors.amber.shade700; // Amarelo escuro para dar leitura no fundo branco
      case 'pouco urgente':
      case 'baixo':
      case 'verde':
        return Colors.green.shade700;
      case 'não urgente':
      case 'nao urgente':
      case 'azul':
        return Colors.blue.shade700;
      default:
        return Colors.grey.shade600; // Caso venha em branco
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "MONGE Hospital - Módulo Médico",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Sair do Sistema",
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── CARD DE IDENTIFICAÇÃO DO MÉDICO ───
          Container(
            width: double.infinity,
            color: Colors.teal.withValues(alpha: 0.1),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.teal,
                  radius: 24,
                  child: Icon(Icons.person, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dr(a). ${widget.doctor.name}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                    Text(
                      "CRM: ${widget.doctor.crm} | Especialidade: ${widget.doctor.specialty}",
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ─── TÍTULO DA LISTA DE PACIENTES ───
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 20.0, bottom: 8.0),
            child: Text(
              "Pacientes em Atendimento / Internados",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),

          // ─── CORPO DINÂMICO ───
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                : _pacientesSobCuidados.isEmpty
                    ? const Center(
                        child: Text(
                          "Nenhum paciente ativo no momento.",
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _pacientesSobCuidados.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemBuilder: (context, index) {
                          final paciente = _pacientesSobCuidados[index];
                          
                          // 🟢 Descobre a cor exata de Manchester para esse paciente
                          final Color corManchester = _obterCorManchester(paciente.riskLevel);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12.0),
                            elevation: 2,
                            clipBehavior: Clip.antiAlias, // Garante que a barra lateral não passe da borda arredondada
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              children: [
                                // 🟢 BARRA LATERAL MANCHESTER: Dá o tom visual de urgência imediatamente
                                Container(
                                  width: 8,
                                  height: 180, // Altura estimada para cobrir o card dinamicamente
                                  color: corManchester,
                                ),
                                
                                // Conteúdo do Card
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(14.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                paciente.name,
                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.teal.shade50,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                paciente.bedId,
                                                style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 12),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        
                                        Text(
                                          "Idade: ${paciente.age} | Convênio: ${paciente.insurance}",
                                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                                        ),
                                        const Divider(height: 20),

                                        Text(
                                          "Observação Clínica:",
                                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800], fontSize: 13),
                                        ),
                                        Text(
                                          paciente.observation,
                                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                                        ),
                                        const SizedBox(height: 10),

                                        if (paciente.isolamento)
                                          Container(
                                            margin: const EdgeInsets.only(bottom: 10),
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade50,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: Colors.red.shade200),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "ISOLAMENTO: ${paciente.tipoIsolamento}",
                                                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            // 🟢 CHIP ATUALIZADO: Exibe a classificação exata com a cor correspondente
                                            Chip(
                                              label: Text(paciente.riskLevel.toUpperCase()),
                                              backgroundColor: corManchester.withValues(alpha: 0.12),
                                              side: BorderSide(color: corManchester, width: 1.5),
                                              labelStyle: TextStyle(color: corManchester, fontWeight: FontWeight.bold, fontSize: 11),
                                              padding: EdgeInsets.zero,
                                            ),
                                            Row(
                                              children: [
                                                TextButton.icon(
                                                  onPressed: () {
                                                    // Evolução do prontuário
                                                  },
                                                  icon: const Icon(Icons.edit_note, color: Colors.teal),
                                                  label: const Text("Evoluir", style: TextStyle(color: Colors.teal)),
                                                ),
                                                const SizedBox(width: 4),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    // Prescrever medicamentos
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.teal,
                                                    foregroundColor: Colors.white,
                                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                                  ),
                                                  child: const Text("Prescrever"),
                                                ),
                                              ],
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
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
}