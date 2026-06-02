// lib/pages/medicos/cadastrar_medico.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../domain/entities/medico.dart';
import '../../../domain/services/medico_service.dart';

class CadastrarMedico extends StatefulWidget {
  final MedicoService service;

  const CadastrarMedico({super.key, required this.service});

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
  final _especialidadeCtrl = TextEditingController(); // ✅ Agora começa vazio!

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _crmCtrl.dispose();
    _telefoneCtrl.dispose();
    _emailCtrl.dispose();
    _honorarioCtrl.dispose();
    _especialidadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.medical_services, color: Colors.teal, size: 28),
                    SizedBox(width: 8),
                    Text("Cadastro de Médico", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))
              ],
            ),
            const Divider(height: 30),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nomeCtrl,
                      decoration: const InputDecoration(labelText: "Nome Completo do Médico *", prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
                      validator: (v) => v == null || v.isEmpty ? "Campo obrigatório" : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _crmCtrl,
                            decoration: const InputDecoration(labelText: "CRM *", prefixIcon: Icon(Icons.badge), border: OutlineInputBorder()),
                            validator: (v) => v == null || v.isEmpty ? "CRM obrigatório" : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _especialidadeCtrl,
                            // ✅ Removido o teclado numérico. Agora é TEXTO LIVRE!
                            decoration: const InputDecoration(labelText: "Especialidade (Ex: Cardiologia) *", prefixIcon: Icon(Icons.category), border: OutlineInputBorder()),
                            validator: (v) => v == null || v.isEmpty ? "Obrigatório" : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _telefoneCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(labelText: "Telefone", prefixIcon: Icon(Icons.phone), border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(labelText: "E-mail", prefixIcon: Icon(Icons.email), border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _honorarioCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: "Valor do Honorário Base (R\$)", prefixIcon: Icon(Icons.attach_money), border: OutlineInputBorder()),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                  icon: const Icon(Icons.save),
                  label: const Text("Salvar Médico"),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        // 1. Cria o Médico SEM ID de especialidade (O Service vai resolver isso)
                        final novoMedico = Medico(
                          nome: _nomeCtrl.text,
                          crm: _crmCtrl.text,
                          telefone: _telefoneCtrl.text.isEmpty ? null : _telefoneCtrl.text,
                          email: _emailCtrl.text.isEmpty ? null : _emailCtrl.text,
                          honorario: _honorarioCtrl.text.isEmpty ? null : double.tryParse(_honorarioCtrl.text.replaceAll(',', '.')),
                        );

                        // 2. Chama a nova função mandando o médico e o nome da especialidade digitada
                        await widget.service.salvarMedicoComEspecialidade(novoMedico, _especialidadeCtrl.text);
                        
                        if (context.mounted) {
                          Navigator.pop(context); 
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Médico cadastrado com sucesso!'), backgroundColor: Colors.teal));
                        }
                      } catch (e) {
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro no banco: $e'), backgroundColor: Colors.red, duration: const Duration(seconds: 6)));
                      }
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}