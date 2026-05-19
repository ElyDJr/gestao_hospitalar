import 'package:flutter/material.dart';
import '../estados/dados_globais.dart';
import '../modelos/modelos_hospitalares.dart';

class TelaMapaLeitos extends StatefulWidget {
  const TelaMapaLeitos({super.key});

  @override
  State<TelaMapaLeitos> createState() => _TelaMapaLeitosState();
}

class _TelaMapaLeitosState extends State<TelaMapaLeitos> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: DadosGlobais.leitos.length,
      itemBuilder: (context, i) {
        final l = DadosGlobais.leitos[i];

        Color cor = Colors.green;
        String txt = "Livre";

        if (l.status == BedStatus.ocupado) {
          cor = Colors.red;
          txt = "Ocupado";
        }

        if (l.status == BedStatus.limpeza) {
          cor = Colors.orange;
          txt = "Limpeza";
        }

        return GestureDetector(
          onTap: () {
            setState(() {
              if (l.status == BedStatus.disponivel) {
                l.status = BedStatus.ocupado;
              } else if (l.status == BedStatus.ocupado) {
                l.status = BedStatus.limpeza;
              } else {
                l.status = BedStatus.disponivel;
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: cor, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bed, color: cor),
                Text(l.id),
                Text(txt),
              ],
            ),
          ),
        );
      },
    );
  }
}