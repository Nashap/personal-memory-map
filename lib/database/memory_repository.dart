import 'package:personal_memory_map/database/database_helper.dart';
import 'package:personal_memory_map/models/memory.dart';
import 'package:personal_memory_map/models/memory_photo.dart';
import 'package:sqflite/sqflite.dart';

class MemoryRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> insert(Memory memory) async {
    final db = await _databaseHelper.database;
    return await db.insert('memories', memory.toMap());
  }

  Future<List<Memory>> getAll() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('memories', orderBy: 'date DESC');
    return maps.map((map) => Memory.fromMap(map)).toList();
  }

  Future<Memory?> getById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'memories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Memory.fromMap(maps.first);
    }
    return null;
  }

  Future<int> update(Memory memory) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'memories',
      memory.toMap(),
      where: 'id = ?',
      whereArgs: [memory.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'memories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAll() async {
    final db = await _databaseHelper.database;
    return await db.delete('memories');
  }

  // --- Photo Operations ---

  Future<int> addPhoto(MemoryPhoto photo) async {
    final db = await _databaseHelper.database;
    return await db.insert('memory_photos', photo.toMap());
  }

  Future<List<MemoryPhoto>> getPhotosForMemory(int memoryId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'memory_photos',
      where: 'memoryId = ?',
      whereArgs: [memoryId],
      orderBy: 'createdAt ASC',
    );
    return maps.map((map) => MemoryPhoto.fromMap(map)).toList();
  }

  Future<int> deletePhoto(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'memory_photos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletePhotosForMemory(int memoryId) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'memory_photos',
      where: 'memoryId = ?',
      whereArgs: [memoryId],
    );
  }

  Future<int> getTotalPhotoCount() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM memory_photos');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getMemoriesWithPhotosCount() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('SELECT COUNT(DISTINCT memoryId) FROM memory_photos');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}

