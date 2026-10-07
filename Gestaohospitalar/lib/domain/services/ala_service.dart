import 'package:flutter/foundation.dart'; // 🟢 Para habilitar o console de Debug
import '../../data/resources/database_provider.dart';
import '../entities/ala.dart';

class AlaService {
  
  Future<List<Ala>> listarAlas() async {
    try {
      final db = await DatabaseProvider.instance.database;
      final List<Map<String, dynamic>> maps = await db.query('ala', orderBy: 'nome_ala');
      
      // 🟢 RASTREAMENTO: Imprime no Console do VS Code/Android Studio
      debugPrint("🟢 BANCO LEU AS ALAS: ${maps.length} registros encontrados no DB.");
      if (maps.isNotEmpty) {
        debugPrint("🟢 EXEMPLO DE DADO DO BANCO: ${maps.first}");
      }
      
      final listaConvertida = maps.map((map) => Ala.fromMap(map)).toList();
      return listaConvertida;
      
    } catch (e) {
      debugPrint("🔴 ERRO CRÍTICO NA CONVERSÃO DA LISTA: $e");
      throw Exception("Falha ao buscar alas no banco: $e");
    }
  }

  Future<void> salvarAla(Ala ala) async {
    final db = await DatabaseProvider.instance.database;
    try {
      if (ala.id == null) {
        // 🟢 INSERÇÃO: Envia o Map com nome_ala, andar e tipo
        await db.insert('ala', ala.toMap());
        debugPrint("🟢 ALA INSERIDA COM SUCESSO: ${ala.nomeAla} (${ala.tipo})");
      } else {
        // 🔵 ATUALIZAÇÃO: Atualiza os dados pelo id_ala
        await db.update('ala', ala.toMap(), where: 'id_ala = ?', whereArgs: [ala.id]);
        debugPrint("🟢 ALA ATUALIZADA COM SUCESSO: ${ala.nomeAla} (${ala.tipo})");
      }
    } catch (e) {
      debugPrint("🔴 ERRO AO SALVAR ALA: $e");
      throw Exception("Falha ao salvar ala: $e");
    }
  }

  Future<void> deletarAla(dynamic id) async {
    try {
      final db = await DatabaseProvider.instance.database;
      await db.delete('ala', where: 'id_ala = ?', whereArgs: [id]);
      debugPrint("🟢 ALA REMOVIDA DO BANCO (ID: $id)");
    } catch (e) {
      debugPrint("🔴 ERRO AO DELETAR ALA: $e");
      throw Exception("Falha ao deletar ala: $e");
    }
  }
}