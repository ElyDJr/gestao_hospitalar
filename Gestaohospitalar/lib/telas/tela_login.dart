import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../pages/dashboard.dart'; 
import '../domain/entities/medico.dart'; 
import '../modelos/modelos_hospitalares.dart'; // Reconhece o 'Doctor'
import 'tela_medicos.dart';       
import 'tela_atendimento_medico.dart';    

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
    final usuarioDigitado = user.text.trim().toLowerCase();
    final senhaDigitada = pass.text.trim(); 

    // VALIDAÇÃO 1: Bloqueia se um dos campos estiver em branco
    if (usuarioDigitado.isEmpty || senhaDigitada.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, preencha o Usuário/CRM e a Senha!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 1. Administrador (Acesso Total)
    if (tipoAcesso == 'ADMIN') {
      if (senhaDigitada == '123456') { 
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Dashboard(database: widget.database),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Senha incorreta para o Administrador!"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    } 
    
    // 2. Busca de médico pelo CRM (Com trava antiqueda)
    if (RegExp(r'^\d+$').hasMatch(usuarioDigitado) || usuarioDigitado.startsWith('crm')) {
      
      try { 
        final List<Map<String, dynamic>> resultado = await widget.database.query(
          'medico',
          where: 'crm = ?',
          whereArgs: [user.text.trim()],
        );

        if (resultado.isNotEmpty) {
          if (senhaDigitada == '123456') { 
            final medicoReal = Medico.fromMap(resultado.first);

            // 🟢 BUSCA A ESPECIALIDADE REAL (Mapeamento Dinâmico Automático)
            String nomeEspecialidade = "Clínica Geral"; 
            if (medicoReal.idEspecialidade != null) {
              // Busca a tabela inteira (como são poucas especialidades, é instantâneo)
              final List<Map<String, dynamic>> espResultado = await widget.database.query('especialidade');
              
              if (espResultado.isNotEmpty) {
                final primeiroRegistro = espResultado.first;
                
                // 🕵️‍♂️ Descobre sozinho qual nome você deu para a coluna de ID
                final chaveId = primeiroRegistro.keys.firstWhere(
                  (k) => k.toLowerCase() == 'id' || 
                        k.toLowerCase() == 'idespecialidade' || 
                        k.toLowerCase() == 'id_especialidade' || 
                        k.toLowerCase().contains('cod'),
                  orElse: () => primeiroRegistro.keys.first,
                );

                // 🕵️‍♂️ Descobre sozinho qual nome você deu para a coluna de Descrição/Nome
                final chaveDesc = primeiroRegistro.keys.firstWhere(
                  (k) => k.toLowerCase().contains('desc') || k.toLowerCase().contains('nome'),
                  orElse: () => primeiroRegistro.keys.last,
                );

                // Filtra a especialidade certa diretamente no Flutter, livre de erros de SQL
                final correspondencia = espResultado.firstWhere(
                  (row) => row[chaveId]?.toString() == medicoReal.idEspecialidade?.toString(),
                  orElse: () => primeiroRegistro,
                );

                nomeEspecialidade = correspondencia[chaveDesc] ?? "Clínica Geral";
              }
            }

            // CONVERSÃO para o modelo 'Doctor'
            final doctorConvertido = Doctor(
              name: medicoReal.nome ?? 'Sem Nome',
              specialty: nomeEspecialidade, 
              crm: medicoReal.crm ?? '',
            );

            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TelaMedico(
                  database: widget.database, 
                  doctor: doctorConvertido,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Senha incorreta para este médico!"),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("CRM não encontrado no sistema!"),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (error) {
        debugPrint("ERRO CRÍTICO NO LOGIN DO MÉDICO: $error");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro detectado: $error"),
            backgroundColor: Colors.purple,
            duration: const Duration(seconds: 10),
          ),
        );
      }
      
      return;
    } 
    
    // 3. Tela de atendimento
    if (usuarioDigitado == 'atendimento' && senhaDigitada == '123456') {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TelaAtendimentoMedico(database: widget.database),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Usuário ou Senha inválidos!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Removido o background do Scaffold para não conflitar com o fundo customizado
      body: Stack(
        children: [
          // ─── CAMADA 1: LOGO GRANDE DE FUNDO ───
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/monge2.jpeg'), // Seu logo
                fit: BoxFit.contain, // Mantém a proporção do logo sem cortar nas bordas
                colorFilter: ColorFilter.mode(
                  Colors.white.withValues(alpha: 0.08), // 0.08 deixa bem suave (estilo marca d'água)
                  BlendMode.dstATop,
                ),
              ),
            ),
          ),
          
          // ─── CAMADA 2: FORMULÁRIO DE LOGIN (NA FRENTE) ───
          Center(
            child: SingleChildScrollView( // Evita erro de quebra de layout ao abrir o teclado
              child: SizedBox(
                width: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      tipoAcesso == "ADMIN" ? "LOGIN ADMINISTRADOR" : "LOGIN MÉDICO",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Radio<String>(
                          value: "MEDICO",
                          groupValue: tipoAcesso,
                          onChanged: (value) {
                            setState(() {
                              tipoAcesso = value!;
                            });
                          },
                        ),
                        const Text("Médico"),
                        const SizedBox(width: 20),
                        Radio<String>(
                          value: "ADMIN",
                          groupValue: tipoAcesso,
                          onChanged: (value) {
                            setState(() {
                              tipoAcesso = value!;
                            });
                          },
                        ),
                        const Text("Administrador"),
                      ],
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: user,
                      decoration: InputDecoration(
                        labelText: tipoAcesso == "ADMIN" ? "Usuário" : "CRM",
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.8), // Fundo levemente branco nos inputs para facilitar a leitura
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: pass,
                      obscureText: true,
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