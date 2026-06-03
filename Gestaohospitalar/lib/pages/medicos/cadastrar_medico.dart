// lib/pages/medicos/cadastrar_medico.dart
import 'package:flutter/material.dart';
import '../../../domain/entities/medico.dart';
import '../../../domain/services/medico_service.dart';

class CadastrarMedico extends StatefulWidget {
  final MedicoService service;
  final Medico? medicoEdicao;

  const CadastrarMedico({super.key, required this.service, this.medicoEdicao});

  @override
  State<CadastrarMedico> createState() => _CadastrarMedicoState();
}

class _CadastrarMedicoState extends State<CadastrarMedico> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _crmCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _honorarioCtrl = TextEditingController();
  final _especialidadeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.medicoEdicao != null) {
      final m = widget.medicoEdicao!;
      _nomeCtrl.text = m.nome ?? '';
      _crmCtrl.text = m.crm ?? '';
      _telefoneCtrl.text = m.telefone ?? '';
      _emailCtrl.text = m.email ?? '';
      _honorarioCtrl.text = m.honorario?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose(); _crmCtrl.dispose(); _telefoneCtrl.dispose(); _emailCtrl.dispose(); _honorarioCtrl.dispose(); _especialidadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdicao = widget.medicoEdicao != null;




   return Container(
  // ✅ Ocupa toda a altura do painel lateral
  height: double.infinity,

  padding: const EdgeInsets.all(24),

  // ✅ Remove as bordas arredondadas do BottomSheet
  // porque agora ele será exibido como painel lateral
  decoration: const BoxDecoration(
    color: Colors.white,
  ),
    
    
    
    
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(isEdicao ? "Editar Médico" : "Novo Médico", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)), IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))]),
            Expanded(child: SingleChildScrollView(child: Column(children: [
              TextFormField(controller: _nomeCtrl, decoration: const InputDecoration(labelText: "Nome Completo *", prefixIcon: Icon(Icons.person), border: OutlineInputBorder())), const SizedBox(height: 16),
              Row(children: [Expanded(child: TextFormField(controller: _crmCtrl, decoration: const InputDecoration(labelText: "CRM *", prefixIcon: Icon(Icons.badge), border: OutlineInputBorder()))), const SizedBox(width: 16), Expanded(child: TextFormField(controller: _especialidadeCtrl, decoration: const InputDecoration(labelText: "Especialidade", prefixIcon: Icon(Icons.local_hospital), border: OutlineInputBorder())))],),
              const SizedBox(height: 16),
              Row(children: [Expanded(child: TextFormField(controller: _telefoneCtrl, decoration: const InputDecoration(labelText: "Telefone", prefixIcon: Icon(Icons.phone), border: OutlineInputBorder()))), const SizedBox(width: 16), Expanded(child: TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email), border: OutlineInputBorder())))],),
              const SizedBox(height: 16),
              TextFormField(controller: _honorarioCtrl, decoration: const InputDecoration(labelText: "Honorário", prefixIcon: Icon(Icons.attach_money), border: OutlineInputBorder())),
            ]))),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: isEdicao ? Colors.blue : Colors.teal, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
              icon: Icon(isEdicao ? Icons.update : Icons.save),
              label: Text(isEdicao ? "Atualizar Médico" : "Salvar Médico"),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final medico = Medico(
                    id: widget.medicoEdicao?.id,
                    ativo: widget.medicoEdicao?.ativo ?? 1,
                    nome: _nomeCtrl.text,
                    crm: _crmCtrl.text,
                    telefone: _telefoneCtrl.text,
                    email: _emailCtrl.text,
                    honorario: double.tryParse(_honorarioCtrl.text.replaceAll(',', '.')),
                  );
                  await widget.service.salvarMedicoComEspecialidade(medico, _especialidadeCtrl.text);
                  
                  // ✅ MENSAGEM DE SUCESSO AQUI
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEdicao ? 'Médico atualizado com sucesso!' : 'Médico cadastrado com sucesso!'),
                        backgroundColor: isEdicao ? Colors.blue : Colors.teal,
                      )
                    );
                  }
                }
              },
            )
          ],
        ),
      ),
    );
  }
}