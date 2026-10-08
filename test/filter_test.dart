import 'package:flutter_test/flutter_test.dart';
import 'package:personal_memory_map/models/memory.dart';
import 'package:personal_memory_map/providers/memory_provider.dart';

// Create a custom subclass or extension to seed data without a DB dependency
// But MemoryProvider requires MemoryRepository. We can test the filtering directly by overriding the internal list for testing.
// Alternatively, since filtering is pure logic, we can test it directly on MemoryProvider by inserting mock data. 
// However, MemoryProvider uses SQLite internally. 
// For unit testing the logic, we can mock the repository, but here we can just test the getters logic via an abstraction or directly by inserting items into the database.
// Let's use the actual SQLite database in memory for testing (sqflite_common_ffi).
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:personal_memory_map/database/database_helper.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('MemoryProvider Filter and Search Tests', () {
    late MemoryProvider provider;

    setUp(() async {
      final db = await DatabaseHelper.instance.database;
      await db.delete('memories');
      await db.delete('memory_photos');

      provider = MemoryProvider();
      
      final memories = [
        Memory(
          title: 'College Graduation',
          description: 'A great day at the university.',
          category: 'College',
          mood: 'Happy',
          latitude: 40.0,
          longitude: -74.0,
          locationName: 'University Campus',
          date: DateTime(2022, 5, 20),
          isFavorite: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Memory(
          title: 'First Job',
          description: 'Started working as an engineer.',
          category: 'Work',
          mood: 'Excited',
          latitude: 37.7,
          longitude: -122.4,
          locationName: 'San Francisco, CA',
          date: DateTime(2023, 8, 15),
          isFavorite: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Memory(
          title: 'Family Vacation',
          description: 'Trip to the mountains with everyone.',
          category: 'Travel',
          mood: 'Peaceful',
          latitude: 45.0,
          longitude: -100.0,
          locationName: 'Rocky Mountains',
          date: DateTime(2026, 12, 10),
          isFavorite: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Memory(
          title: 'Sad Day',
          description: 'Lost my favorite pen in college.',
          category: 'Other',
          mood: 'Sad',
          latitude: null,
          longitude: null,
          locationName: 'Home',
          date: DateTime(2022, 6, 1),
          isFavorite: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      for (var m in memories) {
        await provider.addMemory(m);
      }
      await provider.loadMemories();
    });

    test('1. Search by title', () {
      provider.setSearchQuery('grad');
      final result = provider.filteredMemories;
      expect(result.length, 1);
      expect(result.first.title, 'College Graduation');
    });

    test('2. Search by description', () {
      provider.setSearchQuery('engineer');
      final result = provider.filteredMemories;
      expect(result.length, 1);
      expect(result.first.title, 'First Job');
    });

    test('3. Search by location', () {
      provider.setSearchQuery('francisco');
      final result = provider.filteredMemories;
      expect(result.length, 1);
      expect(result.first.title, 'First Job');
    });

    test('4. Category filter', () {
      provider.setFilterCategory('College');
      final result = provider.filteredMemories;
      expect(result.length, 1);
      expect(result.first.title, 'College Graduation');
    });

    test('5. Mood filter', () {
      provider.setFilterMood('Sad');
      final result = provider.filteredMemories;
      expect(result.length, 1);
      expect(result.first.title, 'Sad Day');
    });

    test('6. Year filter', () {
      provider.setFilterYear(2022);
      final result = provider.filteredMemories;
      expect(result.length, 2);
    });

    test('7. Favorites filter', () {
      provider.setFilterFavoritesOnly(true);
      final result = provider.filteredMemories;
      expect(result.length, 2);
      expect(result.every((m) => m.isFavorite), isTrue);
    });

    test('8. Combined filters', () {
      provider.setSearchQuery('college');
      provider.setFilterYear(2022);
      provider.setFilterFavoritesOnly(true);
      final result = provider.filteredMemories;
      expect(result.length, 1);
      expect(result.first.title, 'College Graduation');
    });

    test('9. Newest-first sorting', () {
      provider.setSortNewestFirst(true);
      final result = provider.filteredMemories;
      expect(result.first.title, 'Family Vacation'); // 2026
      expect(result.last.title, 'College Graduation'); // May 2022
    });

    test('10. Oldest-first sorting', () {
      provider.setSortNewestFirst(false);
      final result = provider.filteredMemories;
      expect(result.first.title, 'College Graduation'); // May 2022
      expect(result.last.title, 'Family Vacation'); // 2026
    });

    test('11. Clear filters', () {
      provider.setSearchQuery('college');
      provider.setFilterYear(2022);
      provider.setFilterFavoritesOnly(true);
      provider.setSortNewestFirst(false);
      
      expect(provider.hasActiveFilters, isTrue);
      
      provider.clearFilters();
      
      expect(provider.hasActiveFilters, isFalse);
      expect(provider.searchQuery, '');
      expect(provider.filterYear, isNull);
      expect(provider.filterFavoritesOnly, isFalse);
      // clearFilters does not change sorting, so it should still be false
      expect(provider.sortNewestFirst, isFalse);
      
      final result = provider.filteredMemories;
      expect(result.length, 4);
    });
  });
}
