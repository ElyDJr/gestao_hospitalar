import 'package:flutter/material.dart';
import '../../domain/entities/escala_medica.dart';
import '../../domain/services/escala_medica_service.dart';
import 'cadastrar_escala_form.dart'; // 🟢 Adicione este import

class AgendaMedicaTela extends StatefulWidget {
  const AgendaMedicaTela({super.key});

  @override
  State<AgendaMedicaTela> createState() => _AgendaMedicaTelaState();
}

class _AgendaMedicaTelaState extends State<AgendaMedicaTela> {
  final EscalaService _escalaService = EscalaService();
  
  DateTime _dataAtual = DateTime.now();
  List<EscalaMedica> _escalasDoMes = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarEscalas();
  }

  Future<void> _carregarEscalas() async {
    setState(() => _carregando = true);
    final escalas = await _escalaService.buscarEscalaDoMes(_dataAtual.year, _dataAtual.month);
    setState(() {
      _escalasDoMes = escalas;
      _carregando = false;
    });
  }

  void _mudarMes(int incremento) {
    setState(() {
      _dataAtual = DateTime(_dataAtual.year, _dataAtual.month + incremento, 1);
    });
    _carregarEscalas();
  }

  // 🟢 NOVA FUNÇÃO: Abre o calendário do sistema para buscar uma data específica
  Future<void> _selecionarData() async {
    final DateTime? escolhida = await showDatePicker(
      context: context,
      initialDate: _dataAtual,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Buscar Data',
      cancelText: 'CANCELAR',
      confirmText: 'BUSCAR',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.teal, // Cor do cabeçalho
              onPrimary: Colors.white, // Cor do texto no cabeçalho
              onSurface: Colors.black, // Cor dos dias
            ),
          ),
          child: child!,
        );
      },
    );

    if (escolhida != null) {
      setState(() {
        // Atualiza a tela para o mês da data escolhida
        _dataAtual = DateTime(escolhida.year, escolhida.month, 1);
      });
      // Recarrega as escalas daquele mês
      await _carregarEscalas();
      
      // Abre automaticamente a lista de médicos do dia escolhido
      if (mounted) {
        _mostrarDetalhesDoDia(escolhida);
      }
    }
  }

  List<EscalaMedica> _escalasDoDia(DateTime dia) {
    String diaFormatado = "${dia.year}-${dia.month.toString().padLeft(2, '0')}-${dia.day.toString().padLeft(2, '0')}";
    return _escalasDoMes.where((e) => e.dataEscala == diaFormatado).toList();
  }

  // 🟢 NOVA FUNÇÃO: Exibe um painel inferior com a lista de médicos do dia clicado
  void _mostrarDetalhesDoDia(DateTime dia) {
    List<EscalaMedica> escalas = _escalasDoDia(dia);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 16),
              Text(
                "Agenda do dia ${dia.day.toString().padLeft(2, '0')}/${dia.month.toString().padLeft(2, '0')}/${dia.year}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const SizedBox(height: 16),
              if (escalas.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text("Nenhum médico escalado para este dia.")),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: escalas.length,
                    itemBuilder: (context, index) {
                      final escala = escalas[index];
                      // return ListTile(
                      //   leading: Icon(Icons.person, color: escala.isPlantao ? Colors.red : Colors.teal),
                      //   title: Text(escala.nomeMedico ?? "Médico", style: const TextStyle(fontWeight: FontWeight.w600)),
                      //   subtitle: Text("${escala.horaInicio} às ${escala.horaFim}"),
                      //   trailing: escala.isPlantao 
                      //     ? Container(
                      //         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      //         decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                      //         child: const Text("PLANTÃO", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      //       ) 
                      //     : null,
                      // );
                      return ListTile(
                        leading: Icon(Icons.person, color: escala.isPlantao ? Colors.red : Colors.teal),
                        title: Text(escala.nomeMedico ?? "Médico", style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text("${escala.horaInicio} às ${escala.horaFim}"),
                        
                        // 🟢 3. MODIFICAÇÃO AQUI NO TRAILING: Substituindo por um Row para agrupar badge + botões
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min, // Impede que ocupe todo o espaço do listTile
                          children: [
                            if (escala.isPlantao)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                                child: const Text("PLANTÃO", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            // Botão de Editar
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                              onPressed: () {
                                Navigator.pop(context); // Fecha o painel inferior antes de abrir o formulário
                                _abrirCadastroEscala(escalaEditar: escala); // Abre o formulário passando a escala
                              },
                            ),
                            // Botão de Excluir
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              onPressed: () => _confirmarExclusao(escala),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _confirmarExclusao(EscalaMedica escala) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Escala'),
        content: Text('Tem certeza que deseja remover o plantão de ${escala.nomeMedico}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text('Cancelar')
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Fecha o AlertDialog
              if (escala.id != null) {
                await _escalaService.excluirEscala(escala.id!);
                _carregarEscalas(); // Atualiza a tela por trás
                if (mounted) Navigator.pop(context); // Fecha o BottomSheet
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Escala removida com sucesso!'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 🟢 NOVA FUNÇÃO: Abre o formulário em formato Drawer lateral direito
  Future<void> _abrirCadastroEscala({EscalaMedica? escalaEditar}) async {
    final atualizou = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Fechar",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            elevation: 10,
            color: Colors.white,
            child: SizedBox(
              width: 450, // Largura ideal de preenchimento para tablets/monitores
              height: double.infinity,
              child: CadastrarEscalaForm(escalaService: _escalaService,
                  escalaParaEditar: escalaEditar),
            ),
          ),
        );
      },
    );

    // Se salvou com sucesso, recarrega o mês atualizado no calendário
    if (atualizou == true) {
      _carregarEscalas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agenda & Plantões Médicos"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 🟢 Controle de Navegação do Mês com Botão de Busca de Data
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => _mudarMes(-1)),
                
                // Botão clicável no texto do mês/ano
                InkWell(
                  onTap: _selecionarData,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Text(
                          "${_nomeMes(_dataAtual.month)} ${_dataAtual.year}",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.search, color: Colors.teal, size: 20),
                      ],
                    ),
                  ),
                ),

                IconButton(icon: const Icon(Icons.arrow_forward_ios), onPressed: () => _mudarMes(1)),
              ],
            ),
          ),
          
          // Cabeçalho dos dias da semana
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _DiaSemanaText("Dom"), _DiaSemanaText("Seg"), _DiaSemanaText("Ter"), 
                _DiaSemanaText("Qua"), _DiaSemanaText("Qui"), _DiaSemanaText("Sex"), _DiaSemanaText("Sáb"),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Calendário Grade
          Expanded(
            child: _carregando 
              ? const Center(child: CircularProgressIndicator())
              : _buildCalendarioGrid(),
          ),
        ],
      ),
      // Altere o botão flutuante da AgendaMedicaTela para chamar nossa função:
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirCadastroEscala, // 🟢 Alterado aqui!
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // 🟢 NOVA FUNÇÃO: Constrói a grade visual do calendário
  Widget _buildCalendarioGrid() {
    // Calcula quantos dias tem no mês atual
    int diasNoMes = DateTime(_dataAtual.year, _dataAtual.month + 1, 0).day;
    
    // Descobre em qual dia da semana cai o dia 1º (No Dart: 1 = Seg, 7 = Dom)
    int primeiroDiaSemana = DateTime(_dataAtual.year, _dataAtual.month, 1).weekday;
    
    // Ajuste: Se o mês começa no Domingo, o offset é 0. Senão, o offset é o próprio valor.
    int offset = primeiroDiaSemana == 7 ? 0 : primeiroDiaSemana;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7, // 7 colunas (Domingo a Sábado)
        childAspectRatio: 0.8, // Altura um pouco maior que a largura
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: diasNoMes + offset,
      itemBuilder: (context, index) {
        // Se o índice for menor que o offset, é um quadrado vazio antes do dia 1º
        if (index < offset) {
          return const SizedBox.shrink();
        }

        // Calcula o dia atual do calendário
        int diaNumero = index - offset + 1;
        DateTime diaAtual = DateTime(_dataAtual.year, _dataAtual.month, diaNumero);
        
        List<EscalaMedica> escalasHoje = _escalasDoDia(diaAtual);
        bool temPlantao = escalasHoje.any((e) => e.isPlantao);
        bool temExpediente = escalasHoje.isNotEmpty && !temPlantao;
        
        // Verifica se é hoje para destacar
        bool isHoje = diaAtual.year == DateTime.now().year && 
                      diaAtual.month == DateTime.now().month && 
                      diaAtual.day == DateTime.now().day;

        return InkWell(
          onTap: () => _mostrarDetalhesDoDia(diaAtual),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: isHoje ? Colors.teal.shade50 : Colors.white,
              border: Border.all(color: isHoje ? Colors.teal : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  diaNumero.toString(),
                  style: TextStyle(
                    fontWeight: isHoje ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                    color: isHoje ? Colors.teal : Colors.black87
                  ),
                ),
                const SizedBox(height: 6),
                // Exibe as bolinhas de status
                if (escalasHoje.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (temExpediente) _buildBolinha(Colors.green),
                      if (temExpediente && temPlantao) const SizedBox(width: 4),
                      if (temPlantao) _buildBolinha(Colors.red),
                    ],
                  )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBolinha(Color cor) {
    return Container(width: 8, height: 8, decoration: BoxDecoration(color: cor, shape: BoxShape.circle));
  }

  String _nomeMes(int mes) {
    const meses = ["Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"];
    return meses[mes - 1];
  }
}

class _DiaSemanaText extends StatelessWidget {
  final String texto;
  const _DiaSemanaText(this.texto);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }
}