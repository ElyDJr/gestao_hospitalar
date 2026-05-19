import 'package:flutter/material.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {

  final user = TextEditingController();
  final pass = TextEditingController();

  void _login() {
    if (user.text == "admin" && pass.text == "123") {
      Navigator.pushReplacementNamed(context, "/home");
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Text("LOGIN HOSPITAL"),

              TextField(controller: user, decoration: const InputDecoration(labelText: "Usuário")),
              TextField(controller: pass, decoration: const InputDecoration(labelText: "Senha"), obscureText: true),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _login,
                child: const Text("Entrar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}