
// lib/domain/services/almoxarifado_service.dart
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../entities/almoxarifado.dart';
import '../repository/entitie_repository.dart';
import '../../data/repositories/generic_repository_impl.dart';

class AlmoxarifadoService extends ChangeNotifier {
  late final EntitieRepository<Almoxarifado> _repository;
  final Database db; // Guardamos a referência aqui
  
  List<Almoxarifado> _itens = [];
  List<Almoxarifado> get itens => _itens;

  // ADICIONE ESTA LINHA:
  bool get temAlertaEstoque => _itens.any((item) => item.quantidade < item.estoqueMinimo);
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AlmoxarifadoService(this.db) {
    _repository = GenericRepositoryImpl<Almoxarifado>(
      db: db,
      tableName: 'almoxarifado',
      fromMap: (map) => Almoxarifado.fromMap(map),
      toMap: (item) => item.toMap(),
    );
  }

  Future<void> carregarItens() async {
    _isLoading = true;
    notifyListeners();
    try {
      _itens = await _repository.findAll();
    } catch (e) {
      debugPrint("Erro ao carregar almoxarifado: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // NOVA FUNÇÃO: Vai buscar os dados à tabela medicamento quando vamos editar
  Future<void> carregarDetalhesMedicamento(Almoxarifado item) async {
    if (item.categoria == 'MEDICAMENTO' && item.id != null) {
      final result = await db.query('medicamento', where: 'id_almoxarifado = ?', whereArgs: [item.id]);
      if (result.isNotEmpty) {
        item.principioAtivo = result.first['principio_ativo'] as String?;
        item.contraindicacoes = result.first['contraindicacoes'] as String?;
      }
    }
  }

  Future<void> salvarItem(Almoxarifado item) async {
    try {
      int idAlmoxarifado;

      // 1. SALVAR NA TABELA ALMOXARIFADO (Pai)
      if (item.id == null) {
        // Usamos db.insert para garantir o retorno imediato do ID
        idAlmoxarifado = await db.insert('almoxarifado', item.toMap());
      } else {
        await _repository.update(item);
        idAlmoxarifado = item.id!;
      }

      // 2. SALVAR NA TABELA MEDICAMENTO (Filha)
      if (item.categoria == 'MEDICAMENTO') {
        final mapMedicamento = {
          'id_almoxarifado': idAlmoxarifado,
          'principio_ativo': item.principioAtivo,
          'contraindicacoes': item.contraindicacoes,
        };

        final existe = await db.query('medicamento', where: 'id_almoxarifado = ?', whereArgs: [idAlmoxarifado]);

        if (existe.isEmpty) {
          await db.insert('medicamento', mapMedicamento);
        } else {
          await db.update('medicamento', mapMedicamento, where: 'id_almoxarifado = ?', whereArgs: [idAlmoxarifado]);
        }
      } else {
        // Se mudarem a categoria de "Medicamento" para outra, limpa os dados antigos
        await db.delete('medicamento', where: 'id_almoxarifado = ?', whereArgs: [idAlmoxarifado]);
      }

      await carregarItens();
    } catch (e) {
      debugPrint("Erro ao salvar item no almoxarifado: $e");
      rethrow;
    }
  }

  Future<void> deletarItem(int id) async {
    await db.delete('medicamento', where: 'id_almoxarifado = ?', whereArgs: [id]); // Apaga primeiro a FK
    await _repository.delete(id);
    await carregarItens();
  }
}