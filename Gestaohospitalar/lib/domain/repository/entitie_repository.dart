// classe generica para todas as entidades
import '../entities/entitie.dart';

abstract class EntitieRepository<T extends Entitie> {
  Future<int> create(T entity);
  Future<int> update(T entity);
  Future<int> delete(int id);
  Future<List<T>> findAll();
}