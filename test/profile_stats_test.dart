import 'package:flutter_test/flutter_test.dart';
import 'package:personal_memory_map/models/memory.dart';
import 'package:personal_memory_map/providers/memory_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:personal_memory_map/database/database_helper.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('MemoryProvider Statistics and Clear Tests', () {
    late MemoryProvider provider;

    setUp(() async {
      final db = await DatabaseHelper.instance.database;
      await db.delete('memories');
      await db.delete('memory_photos');

      provider = MemoryProvider();
      
      final memories = [
        Memory(
          title: 'A',
          description: 'A',
          category: 'College',
          mood: 'Happy',
          latitude: 10.0,
          longitude: 10.0,
          locationName: 'Loc 1',
          date: DateTime(2025, 1, 1),
          isFavorite: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Memory(
          title: 'B',
          description: 'B',
          category: 'College',
          mood: 'Excited',
          latitude: null,
          longitude: null,
          locationName: null,
          date: DateTime(2025, 2, 1),
          isFavorite: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Memory(
          title: 'C',
          description: 'C',
          category: 'Work',
          mood: 'Peaceful',
          latitude: 20.0,
          longitude: 20.0,
          locationName: 'Loc 1',
          date: DateTime(2026, 1, 1),
          isFavorite: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      for (var m in memories) {
        await provider.addMemory(m);
      }
      await provider.loadMemories();
    });

    test('1. Total memory count', () {
      expect(provider.totalMemories, 3);
    });

    test('2. Favorite count', () {
      expect(provider.favoriteCount, 2);
    });

    test('3. Memories with locations', () {
      expect(provider.memoriesWithLocations, 2);
    });

    test('4. Category counts', () {
      final counts = provider.categoryCounts;
      expect(counts['College'], 2);
      expect(counts['Work'], 1);
    });

    test('5. Year counts', () {
      final counts = provider.yearCounts;
      expect(counts[2025], 2);
      expect(counts[2026], 1);
    });

    test('6. Clear-all behavior', () async {
      expect(provider.totalMemories, 3);
      await provider.clearAll();
      expect(provider.totalMemories, 0);
      expect(provider.favoriteCount, 0);
      expect(provider.memoriesWithLocations, 0);
      expect(provider.categoryCounts.isEmpty, isTrue);
      expect(provider.yearCounts.isEmpty, isTrue);
    });

    test('7. Photo count through provider', () async {
      // Photo logic can be partly tested by default state
      expect(provider.totalPhotoCount, 0);
      expect(provider.memoriesWithPhotosCount, 0);
    });
  });
}
