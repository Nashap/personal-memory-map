import 'package:flutter_test/flutter_test.dart';
import 'package:personal_memory_map/models/memory.dart';
import 'package:personal_memory_map/database/memory_repository.dart';
import 'package:personal_memory_map/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';


void main() {
  setUpAll(() {
    // Initialize FFI for unit tests on desktop
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('MemoryRepository Tests', () {
    late MemoryRepository repository;
    
    setUp(() async {
      // In-memory database for testing
      DatabaseHelper.instance; // ensure initialized
      repository = MemoryRepository();
      // We will override the db path or mock but since database_helper uses getDatabasesPath(),
      // databaseFactoryFfi handles it and stores in memory if we use inMemoryDatabasePath
      // To strictly use inMemory:
      // However, we didn't mock DatabaseHelper. 
      // It's easier to clear the real test db before each test.
      await repository.deleteAll();
    });

    tearDown(() async {
      await repository.deleteAll();
    });

    final testMemory = Memory(
      title: 'Test Memory',
      description: 'This is a test',
      date: DateTime.now(),
      category: 'Test',
      mood: 'Happy',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isFavorite: false,
    );

    test('1. Insert memory', () async {
      final id = await repository.insert(testMemory);
      expect(id, isNotNull);
      expect(id, isPositive);
    });

    test('2. Retrieve memory', () async {
      final id = await repository.insert(testMemory);
      final retrieved = await repository.getById(id);
      expect(retrieved, isNotNull);
      expect(retrieved!.id, id);
      expect(retrieved.title, 'Test Memory');
    });

    test('3. Retrieve all memories', () async {
      await repository.insert(testMemory);
      await repository.insert(testMemory.copyWith(title: 'Second Test'));
      
      final all = await repository.getAll();
      expect(all.length, 2);
    });

    test('4. Update memory', () async {
      final id = await repository.insert(testMemory);
      final retrieved = await repository.getById(id);
      
      final updated = retrieved!.copyWith(title: 'Updated Title', isFavorite: true);
      await repository.update(updated);
      
      final retrievedAfterUpdate = await repository.getById(id);
      expect(retrievedAfterUpdate!.title, 'Updated Title');
      expect(retrievedAfterUpdate.isFavorite, true);
    });

    test('5. Delete memory', () async {
      final id = await repository.insert(testMemory);
      var all = await repository.getAll();
      expect(all.length, 1);
      
      await repository.delete(id);
      
      all = await repository.getAll();
      expect(all.isEmpty, true);
    });

    test('6. Delete all memories', () async {
      await repository.insert(testMemory);
      await repository.insert(testMemory);
      var all = await repository.getAll();
      expect(all.length, 2);
      
      await repository.deleteAll();
      
      all = await repository.getAll();
      expect(all.isEmpty, true);
    });
  });
}
