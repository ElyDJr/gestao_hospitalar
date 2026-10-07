// lib/pages/arquivo/tela_arquivo.dart
import 'package:flutter/material.dart';

class TelaArquivo extends StatefulWidget {
  final String titulo;
  final Future<List<Map<String, dynamic>>> Function() carregarArquivados;
  final Future<void> Function(int id) restaurar;

  const TelaArquivo({
    super.key,
    required this.titulo,
    required this.carregarArquivados,
    required this.restaurar,
  });

  /// Função estática auxiliar para chamar a confirmação de arquivamento em outras telas.
  static Future<bool> confirmarArquivamento({
    required BuildContext context,
    required String nomeItem,
  }) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar Arquivamento'),
        content: Text('Tem certeza que deseja arquivar "$nomeItem"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Arquivar'),
          ),
        ],
      ),
    );
    return confirmou ?? false;
  }

  @override
  State<TelaArquivo> createState() => _TelaArquivoState();
}

class _TelaArquivoState extends State<TelaArquivo> {
  List<Map<String, dynamic>> todos = [];
  String busca = '';

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final dados = await widget.carregarArquivados();
    setState(() => todos = dados);
  }

  String _norm(String s) => s
      .toLowerCase()
      .replaceAll(RegExp('[áàâãä]'), 'a')
      .replaceAll(RegExp('[éèêë]'), 'e')
      .replaceAll(RegExp('[íìîï]'), 'i')
      .replaceAll(RegExp('[óòôõö]'), 'o')
      .replaceAll(RegExp('[úùûü]'), 'u')
      .replaceAll('ç', 'c');

  String _digitos(String s) => s.replaceAll(RegExp(r'\D'), '');

  List<Map<String, dynamic>> get filtrados {
    final q = busca.trim();
    if (q.isEmpty) return todos;
    final qNome = _norm(q);
    final qNum = _digitos(q);
    return todos.where((p) {
      final nomeOk = _norm('${p['nome'] ?? ''}').contains(qNome);
      final numOk = qNum.isNotEmpty &&
          (_digitos('${p['cpf'] ?? ''}').contains(qNum) ||
              _digitos('${p['rg'] ?? ''}').contains(qNum));
      return nomeOk || numOk;
    }).toList();
  }

  Future<void> _abrirItem(Map<String, dynamic> item) async {
    final restaurar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${item['nome']}'),
        content: Text(
          'CPF: ${item['cpf'] ?? '-'}\n'
          'Identidade: ${item['rg'] ?? '-'}\n\n'
          'Deseja restaurar este registro?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Fechar'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.restore),
            label: const Text('Restaurar'),
          ),
        ],
      ),
    );

    if (restaurar == true) {
      await widget.restaurar(item['id'] as int);
      await _carregar(); // Recarrega a lista para remover o item restaurado da visualização
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.titulo)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar por nome, CPF ou identidade',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => busca = v),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filtrados.isEmpty
                  ? const Center(
                      child: Text('Nenhum registro arquivado encontrado'),
                    )
                  : ListView.builder(
                      itemCount: filtrados.length,
                      itemBuilder: (_, i) {
                        final p = filtrados[i];
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text('${p['nome']}'),
                          subtitle: Text('CPF: ${p['cpf'] ?? '-'}'),
                          onTap: () => _abrirItem(p),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}