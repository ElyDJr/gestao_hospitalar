// lib/pages/login/tela_login.dart
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../dashboard.dart';
import '../dashboard_medico.dart';

import '../../domain/services/auth_service.dart';

class TelaLogin extends StatefulWidget {
  final Database database;

  const TelaLogin({super.key, required this.database});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final user = TextEditingController();
  final pass = TextEditingController();

  String tipoAcesso = "MEDICO";

  @override
  void dispose() {
    user.dispose();
    pass.dispose();
    super.dispose();
  }

  void _login() async {
    final usuarioDigitado = user.text.trim();
    final senhaDigitada = pass.text.trim();

    if (usuarioDigitado.isEmpty || senhaDigitada.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Preencha todos os campos!")));
      return;
    }

    if (tipoAcesso == 'ADMIN') {
      if (senhaDigitada == '123456') {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => Dashboard(database: widget.database)));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Senha incorreta!")));
      }
      return;
    }

    // 🟢 USO DO NOVO SERVIÇO DE AUTENTICAÇÃO
    final authService = AuthService(widget.database);
    final medico =
        await authService.autenticarMedico(usuarioDigitado, senhaDigitada);

    if (medico != null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => DashboardMedico(database: widget.database)),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("CRM ou senha incorretos!"),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child:
                // ─── CAMADA 1: LOGO DE FUNDO ───
                Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('assets/imagens/monge.jpeg'),
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(
                    Colors.white.withValues(alpha: 0.08),
                    BlendMode.dstATop,
                  ),
                ),
              ),
            ),
          ),
          // ─── CAMADA 2: FORMULÁRIO DE LOGIN ───
          Center(
            child: SingleChildScrollView(
              child: SizedBox(
                width: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      tipoAcesso == "ADMIN"
                          ? "LOGIN ADMINISTRADOR"
                          : "LOGIN MÉDICO",
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Radio<String>(
                          value: "MEDICO",
                          groupValue: tipoAcesso,
                          onChanged: (value) =>
                              setState(() => tipoAcesso = value!),
                        ),
                        const Text("Médico"),
                        const SizedBox(width: 20),
                        Radio<String>(
                          value: "ADMIN",
                          groupValue: tipoAcesso,
                          onChanged: (value) =>
                              setState(() => tipoAcesso = value!),
                        ),
                        const Text("Administrador"),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: user,
                      textInputAction: TextInputAction.next, // O Enter aqui pula para o próximo campo
                      decoration: InputDecoration(
                        labelText: tipoAcesso == "ADMIN" ? "Usuário" : "CRM",
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: pass,
                      obscureText: true,
                      textInputAction: TextInputAction.done, // Transforma o botão do teclado em "Concluído/Enter"
                      onSubmitted: (_) => _login(), // Aciona o login ao apertar Enter
                      decoration: InputDecoration(
                        labelText: "Senha",
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      onPressed: _login,
                      child: const Text("Entrar"),
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