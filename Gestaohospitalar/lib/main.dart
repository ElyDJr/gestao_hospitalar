import 'package:flutter/material.dart';

import 'telas/tela_painel.dart';

void main() {
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
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),

      home: const TelaPainel(),
    );
  }
}