import 'package:flutter/material.dart';
import '../../data/resources/database_provider.dart';
import '../../domain/entities/escala_medica.dart';
import '../../domain/services/escala_medica_service.dart';

class CadastrarEscalaForm extends StatefulWidget {
  final EscalaService escalaService;
  const CadastrarEscalaForm({super.key, required this.escalaService});

  @override
  State<CadastrarEscalaForm> createState() => _CadastrarEscalaFormState();
}

class _CadastrarEscalaFormState extends State<CadastrarEscalaForm> {
  final _formKey = GlobalKey<FormState>();
  
  int? _idMedicoSelecionado;
  DateTime? _dataSelecionada;
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFim;
  bool _isPlantao = false;

  List<Map<String, dynamic>> _medicosAtivos = [];
  bool _carregandoMedicos = true;

  @override
  void initState() {
    super.initState();
    _carregarMedicos();
  }

  // Busca os médicos ativos diretamente do banco
  Future<void> _carregarMedicos() async {
    try {
      final db = await DatabaseProvider.instance.database;
      final res = await db.query('medico', where: 'ativo != 0', orderBy: 'nome');
      setState(() {
        _medicosAtivos = res;
        _carregandoMedicos = false;
      });
    } catch (e) {
      debugPrint("Erro ao carregar médicos: $e");
    }
  }

  // Seletor de Data Nativo
  Future<void> _selecionarData() async {
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (escolhida != null) {
      setState(() => _dataSelecionada = escolhida);
    }
  }

  // Seletor de Horário Nativo
  Future<void> _selecionarHora(bool isInicio) async {
    final escolhida = await showTimePicker(
      context: context,
      initialTime: isInicio
          ? (_horaInicio ?? const TimeOfDay(hour: 08, minute: 00))
          : (_horaFim ?? const TimeOfDay(hour: 18, minute: 00)),
    );
    if (escolhida != null) {
      setState(() {
        if (isInicio) {
          _horaInicio = escolhida;
        } else {
          _horaFim = escolhida;
        }
      });
    }
  }

  String _formatarTimeOfDay(TimeOfDay? time) {
    if (time == null) return "Não selecionado";
    final hora = time.hour.toString().padLeft(2, '0');
    final minuto = time.minute.toString().padLeft(2, '0');
    return "$hora:$minuto";
  }

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      if (_dataSelecionada == null || _horaInicio == null || _horaFim == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, preencha a data e os horários!'), backgroundColor: Colors.orange),
        );
        return;
      }

      // Formata a data para YYYY-MM-DD
      String dataFormatada = "${_dataSelecionada!.year}-${_dataSelecionada!.month.toString().padLeft(2, '0')}-${_dataSelecionada!.day.toString().padLeft(2, '0')}";

      final novaEscala = EscalaMedica(
        idMedico: _idMedicoSelecionado!,
        dataEscala: dataFormatada,
        horaInicio: _formatarTimeOfDay(_horaInicio),
        horaFim: _formatarTimeOfDay(_horaFim),
        isPlantao: _isPlantao,
      );

      await widget.escalaService.cadastrarEscala(novaEscala);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Turno agendado com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Retorna true para recarregar o calendário
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Escala Médica'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _carregandoMedicos 
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Seletor de Médico
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Médico Disponível *',
                        prefixIcon: Icon(Icons.person, color: Colors.teal),
                      ),
                      value: _idMedicoSelecionado,
                      items: _medicosAtivos.map((m) {
                        return DropdownMenuItem<int>(
                          value: m['id_medico'] as int,
                          child: Text(m['nome'].toString()),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _idMedicoSelecionado = val),
                      validator: (value) => value == null ? 'Selecione o Médico' : null,
                    ),
                    const SizedBox(height: 20),

                    // Campo de Data Customizado
                    ListTile(
                      leading: const Icon(Icons.calendar_month, color: Colors.teal),
                      title: const Text("Data da Escala"),
                      subtitle: Text(_dataSelecionada == null 
                          ? "Clique para escolher..." 
                          : "${_dataSelecionada!.day.toString().padLeft(2, '0')}/${_dataSelecionada!.month.toString().padLeft(2, '0')}/${_dataSelecionada!.year}"),
                      tileColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      onTap: _selecionarData,
                    ),
                    const SizedBox(height: 16),

                    // Linha com Horário de Início e Término
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            leading: const Icon(Icons.access_time, color: Colors.green),
                            title: const Text("Início"),
                            subtitle: Text(_formatarTimeOfDay(_horaInicio)),
                            tileColor: Colors.grey.shade100,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            onTap: () => _selecionarHora(true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ListTile(
                            leading: const Icon(Icons.access_time_filled, color: Colors.red),
                            title: const Text("Término"),
                            subtitle: Text(_formatarTimeOfDay(_horaFim)),
                            tileColor: Colors.grey.shade100,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            onTap: () => _selecionarHora(false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Chave de seleção se é plantonista
                    SwitchListTile(
                      title: const Text("Médico de Plantão?", style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text("Ative se for cobertura de urgência/emergência 24h"),
                      value: _isPlantao,
                      activeColor: Colors.red,
                      secondary: Icon(Icons.warning, color: _isPlantao ? Colors.red : Colors.grey),
                      onChanged: (val) => setState(() => _isPlantao = val),
                    ),
                    const Spacer(),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal, 
                        foregroundColor: Colors.white, 
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                      ),
                      onPressed: _salvar,
                      child: const Text('Salvar Escala no Calendário', style: TextStyle(fontSize: 16)),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}