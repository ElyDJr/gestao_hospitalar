// lib/domain/services/almoxarifado_service.dart
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../entities/almoxarifado.dart';
import '../repository/entitie_repository.dart';
import '../../data/repositories/generic_repository_impl.dart';

class AlmoxarifadoService extends ChangeNotifier {
  late final EntitieRepository<Almoxarifado> _repository;
  final Database db;
  
  List<Almoxarifado> _itens = [];
  List<Almoxarifado> get itens => _itens;

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

  Future<void> carregarDetalhesMedicamento(Almoxarifado item) async {
    // 🟢 Acesso seguro usando ?.
    if (item.categoria?.toUpperCase() == 'MEDICAMENTO' && item.id != null) {
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

      if (item.id == null) {
        idAlmoxarifado = await db.insert('almoxarifado', item.toMap());
      } else {
        await _repository.update(item);
        idAlmoxarifado = item.id!;
      }

      // 🟢 Acesso seguro usando ?.
      if (item.categoria?.toUpperCase() == 'MEDICAMENTO') {
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
        await db.delete('medicamento', where: 'id_almoxarifado = ?', whereArgs: [idAlmoxarifado]);
      }

      await carregarItens();
    } catch (e) {
      debugPrint("Erro ao salvar item no almoxarifado: $e");
      rethrow;
    }
  }

  Future<void> deletarItem(int id) async {
    await db.delete('medicamento', where: 'id_almoxarifado = ?', whereArgs: [id]);
    await _repository.delete(id);
    await carregarItens();
  }

  // 🟢 Método de exclusão por entidade
  Future<void> arquivarItem(Almoxarifado item) async {
    if (item.id != null) {
      await deletarItem(item.id!);
    }
  }
}