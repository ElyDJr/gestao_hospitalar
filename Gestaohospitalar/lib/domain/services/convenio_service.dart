// lib/domain/services/convenio_service.dart
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../entities/convenio.dart';
import '../repository/entitie_repository.dart';
import '../../data/repositories/generic_repository_impl.dart';

class ConvenioService extends ChangeNotifier {
  late final EntitieRepository<Convenio> _repository;
  
  List<Convenio> _convenios = [];
  List<Convenio> get convenios => _convenios;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ConvenioService(Database db) {
    _repository = GenericRepositoryImpl<Convenio>(
      db: db,
      tableName: 'convenio',
      fromMap: (map) => Convenio.fromMap(map),
      toMap: (c) => c.toMap(),
    );
  }

  Future<void> carregarConvenios() async {
    _isLoading = true;
    notifyListeners();
    final todos = await _repository.findAll();
    // Filtra apenas ativos
    _convenios = todos.where((c) => c.ativo != 0).toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> salvarConvenio(Convenio convenio) async {
    if (convenio.id == null) {
      await _repository.create(convenio);
    } else {
      await _repository.update(convenio);
    }
    await carregarConvenios();
  }

  Future<void> arquivarConvenio(Convenio convenio) async {
    await _repository.update(convenio.copyWith(ativo: 0));
    await carregarConvenios();
  }
}