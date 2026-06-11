import 'package:flutter/material.dart';
import '../../domain/entities/paciente.dart';
// Importe suas entidades e services aqui...

class EncaminhamentoForm extends StatefulWidget {
  final Paciente paciente;
  final Map<String, dynamic> triagem;
  //final String tipoDestino; // 'SALA' ou 'INTERNACAO'
  final dynamic database;

  const EncaminhamentoForm({super.key, required this.paciente, required this.triagem, required this.database});

  @override
  State<EncaminhamentoForm> createState() => _EncaminhamentoFormState();
}

class _EncaminhamentoFormState extends State<EncaminhamentoForm> {
  String _tipoDestino = 'SALA';
  final String _riscoEvasao = 'BAIXO';
  final String _isolamento = 'NAO';
  
  // Variáveis de destino
  int? _idMedicoSelecionado;
  int? _idSalaSelecionada;
  int? _idLeitoSelecionado;

  List<Map<String, dynamic>> _medicos = [];

  @override
  void initState() {
    super.initState();
    _carregarMedicos(); // Busca os médicos do banco para o Select
  }

  Future<void> _carregarMedicos() async {
    final medicos = await widget.database.query('medico');
    setState(() => _medicos = medicos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Encaminhamento para ${_tipoDestino == 'SALA' ? "Sala/Consultório" : "Internação"}",
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. INFORMAÇÕES DO PACIENTE (Leitura)
            Card(
              child: ListTile(
                title: const Text("1. Dados do Paciente", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Nome: ${widget.paciente.nome}\nCPF: ${widget.paciente.cpf}\nData Nasc: ${widget.paciente.nascimento}\nSexo: ${widget.paciente.sexo}"),
              ),
            ),
            
            // 2. INFORMAÇÕES DA TRIAGEM (Leitura)
            Card(
              child: ListTile(
                title: const Text("2. Dados da Triagem", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("PA: ${widget.triagem['pressao']} | Temp: ${widget.triagem['temperatura']}°C | Sat: ${widget.triagem['saturacao']}%\n"
                "Risco: ${widget.triagem['risco']}\nQueixa: ${widget.triagem['queixa']}\n"
                "Alergias: ${widget.triagem['alergias'] ?? "Não relatado"}"),
              ),
            ),

            // 3. DEFINIR DESTINO E MÉDICO
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("3. Definir Destino", style: TextStyle(fontWeight: FontWeight.bold)),
                    
                    // 🟢 ESCOLHA DE INTERNAÇÃO OU SALA AQUI
                    Row(
                      children: [
                        Expanded(child: RadioListTile<String>(title: const Text("Sala/Consultório"), value: 'SALA', groupValue: _tipoDestino, onChanged: (v) => setState(() => _tipoDestino = v!))),
                        Expanded(child: RadioListTile<String>(title: const Text("Internação/Leito"), value: 'INTERNACAO', groupValue: _tipoDestino, onChanged: (v) => setState(() => _tipoDestino = v!))),
                      ],
                    ),

                    // 🟢 ESCOLHA DO MÉDICO (Resolve o erro 1299 NOT NULL)
                    DropdownButtonFormField<int>(
                      initialValue: _idMedicoSelecionado,
                      items: _medicos.map((m) => DropdownMenuItem<int>(value: m['id_medico'] as int, child: Text(m['nome']))).toList(),
                      onChanged: (v) => setState(() => _idMedicoSelecionado = v),
                      decoration: const InputDecoration(labelText: "Médico Responsável *"),
                    ),
                    const SizedBox(height: 10),

                    if (_tipoDestino == 'SALA')
                      DropdownButtonFormField<int>(
                        initialValue: _idSalaSelecionada,
                        items: const [
                          DropdownMenuItem(value: 1, child: Text("Consultório 01 - Triagem")),
                          DropdownMenuItem(value: 2, child: Text("Consultório 02 - Especialidades")),
                        ],
                        onChanged: (v) => setState(() => _idSalaSelecionada = v),
                        decoration: const InputDecoration(labelText: "Selecione a Sala *"),
                      ),

                    if (_tipoDestino == 'INTERNACAO')
                      DropdownButtonFormField<int>(
                        initialValue: _idLeitoSelecionado,
                        items: const [
                          DropdownMenuItem(value: 1, child: Text("Leito UTI - 01")),
                          DropdownMenuItem(value: 2, child: Text("Leito Enfermaria - 05")),
                        ],
                        onChanged: (v) => setState(() => _idLeitoSelecionado = v),
                        decoration: const InputDecoration(labelText: "Selecione o Leito Vago *"),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: _finalizarFluxo,
              child: const Text("Salvar e Enviar para o Médico"),
            )
          ],
        ),
      ),
    );
  }

  void _finalizarFluxo() async {
    // Validações obrigatórias
    if (_idMedicoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Selecione um Médico!"), backgroundColor: Colors.red));
      return;
    }
    if (_tipoDestino == 'SALA' && _idSalaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Selecione uma Sala!"), backgroundColor: Colors.red));
      return;
    }
    if (_tipoDestino == 'INTERNACAO' && _idLeitoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Selecione um Leito!"), backgroundColor: Colors.red));
      return;
    }

    try {
      // 1. CRIA O PRONTUÁRIO (Com o id_medico resolvendo o erro)
      int idProntuario = await widget.database.insert('prontuario', {
        'id_paciente': widget.paciente.id,
        'id_triagem': widget.triagem['id_triagem'],
        'id_medico': _idMedicoSelecionado, // 🟢 ERRO 1299 RESOLVIDO
        'id_sala': _tipoDestino == 'SALA' ? _idSalaSelecionada : null,
        'risco_evasao': _riscoEvasao,
        'isolamento': _isolamento,
        'data_abertura': DateTime.now().toIso8601String(),
        'status_prontuario': 'ATIVO', // 🟢 ATIVO GARANTIDO
      });

      // 2. SE FOR INTERNAÇÃO, CRIA NA TABELA INTERNACAO
      if (_tipoDestino == 'INTERNACAO') {
        await widget.database.insert('internacao', {
          'id_prontuario': idProntuario,
          'id_leito': _idLeitoSelecionado,
          'data_entrada': DateTime.now().toIso8601String(),
        });
      }

      String valorInternacao = (_tipoDestino == 'INTERNACAO') ? 'SIM' : 'NAO';

      // 3. (OPCIONAL Mas recomendado) Atualiza a triagem dizendo que ele foi encaminhado para sair da fila inicial
      await widget.database.update(
        'triagem', 
        {'internacao': valorInternacao}, // Agora envia apenas 'SIM' ou 'NAO'
        where: 'id_triagem = ?', 
        whereArgs: [widget.triagem['id_triagem']]
      );

      if (mounted) {
        Navigator.pop(context); // Fecha o form lateral
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Encaminhamento realizado com sucesso!"), backgroundColor: Colors.green));
      }
    } catch (e) {
      debugPrint("ERRO AO SALVAR: $e");
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red));
    }
  }
}