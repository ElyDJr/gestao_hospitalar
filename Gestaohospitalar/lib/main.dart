// lib/main.dart
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'data/resources/database_provider.dart'; // Ajuste se a sua pasta for resources ou datasources
import 'pages/tela_painel.dart';

void main() {
  // Garante que o motor do Flutter esteja pronto antes de carregar o banco na Web
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MongeApp());
}

class MongeApp extends StatelessWidget {
  const MongeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MONGE Hospital',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      // Usamos o FutureBuilder para esperar o arquivo .db carregar no navegador
      home: FutureBuilder<Database>(
        future: DatabaseProvider.instance.database,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Colors.teal),
              ),
            );
          }
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text(
                  'Erro ao carregar o banco de dados: ${snapshot.error}',
                ),
              ),
            );
          }

          // ✅ ERRO RESOLVIDO: Passando a conexão com o banco para a TelaPainel
          return TelaPainel(database: snapshot.data!);
        },
      ),
    );
  }
}
