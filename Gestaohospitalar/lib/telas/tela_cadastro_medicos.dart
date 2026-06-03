import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart'; // 🟢 Import do SQLite
import '../modelos/modelos_hospitalares.dart';

class TelaCadastroMedicos extends StatefulWidget {
  final Database database; // 🟢 Agora a tela recebe o acesso ao banco

  const TelaCadastroMedicos({super.key, required this.database});

  @override
  State<TelaCadastroMedicos> createState() => _TelaCadastroMedicosState();
}

class _TelaCadastroMedicosState extends State<TelaCadastroMedicos> {
  List<Doctor> _medicosReais = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarMedicosDoBanco();
  }

  // 🟢 Carrega os médicos salvos no SQLite
  Future<void> _carregarMedicosDoBanco() async {
    setState(() => _isLoading = true);
    try {
      // Faz a consulta direto na tabela correspondente aos médicos (ex: 'medico' ou 'doctor')
      final List<Map<String, dynamic>> maps = await widget.database.query('medico');
      
      setState(() {
        _medicosReais = maps.map((map) {
          return Doctor(
            name: map['nome'] ?? map['name'] ?? 'Sem Nome',
            crm: map['crm'] ?? '',
            specialty: map['especialidade'] ?? map['specialty'] ?? '',
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Erro ao carregar médicos: $e");
      setState(() => _isLoading = false);
    }
  }

  // 🟢 Salva o novo médico no banco de dados SQLite
  Future<void> _salvarMedicoNoBanco(Doctor doctor) async {
    try {
      await widget.database.insert(
        'medico', // Certifique-se de que o nome da tabela no seu banco é 'medico'
        {
          'nome': doctor.name,
          'crm': doctor.crm,
          'especialidade': doctor.specialty,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      // Recarrega a lista para atualizar a tela
      _carregarMedicosDoBanco();
    } catch (e) {
      debugPrint("Erro ao salvar médico: $e");
    }
  }

  void _novoMedico() {
    final nome = TextEditingController();
    final crm = TextEditingController();
    final especialidade = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Novo Médico"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nome,
                  decoration: const InputDecoration(labelText: "Nome"),
                ),
                TextField(
                  controller: crm,
                  decoration: const InputDecoration(labelText: "CRM"),
                ),
                TextField(
                  controller: especialidade,
                  decoration: const InputDecoration(labelText: "Especialidade"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nome.text.isNotEmpty && crm.text.isNotEmpty) {
                    final novoDoc = Doctor(
                      name: nome.text,
                      specialty: especialidade.text,
                      crm: crm.text,
                    );
                    
                    // 🟢 Chama a função para persistir no banco real
                    await _salvarMedicoNoBanco(novoDoc);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: const Text("Salvar"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _novoMedico,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : _medicosReais.isEmpty
              ? const Center(
                  child: Text(
                    "Nenhum médico cadastrado no sistema.",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _medicosReais.length,
                  itemBuilder: (_, i) {
                    final m = _medicosReais[i];

                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: Icon(Icons.medical_services, color: Colors.white, size: 20),
                        ),
                        title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("CRM: ${m.crm} | Especialidade: ${m.specialty}"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                    );
                  },
                ),
    );
  }
}