import 'dart:io';
import 'package:flutter/material.dart';
import 'package:personal_memory_map/models/memory.dart';
import 'package:personal_memory_map/models/memory_photo.dart';
import 'package:personal_memory_map/database/memory_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class MemoryProvider with ChangeNotifier {
  final MemoryRepository _repository = MemoryRepository();
  List<Memory> _memories = [];
  bool _isLoading = false;
  String? _error;

  List<Memory> get memories => _memories;
  List<Memory> get favoriteMemories => _memories.where((m) => m.isFavorite).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  // --- Statistics ---
  int get totalMemories => _memories.length;
  int get favoriteCount => _memories.where((m) => m.isFavorite).length;
  int get memoriesWithLocations => _memories.where((m) => m.latitude != null && m.longitude != null).length;

  Map<String, int> get categoryCounts {
    final counts = <String, int>{};
    for (var m in _memories) {
      counts[m.category] = (counts[m.category] ?? 0) + 1;
    }
    return counts;
  }
  
  Map<int, int> get yearCounts {
    final counts = <int, int>{};
    for (var m in _memories) {
      final year = m.date.year;
      counts[year] = (counts[year] ?? 0) + 1;
    }
    return counts;
  }

  int _totalPhotoCount = 0;
  int _memoriesWithPhotosCount = 0;

  int get totalPhotoCount => _totalPhotoCount;
  int get memoriesWithPhotosCount => _memoriesWithPhotosCount;

  Future<void> _updatePhotoStats() async {
    _totalPhotoCount = await _repository.getTotalPhotoCount();
    _memoriesWithPhotosCount = await _repository.getMemoriesWithPhotosCount();
    notifyListeners();
  }

  // --- Filtering & Sorting State ---
  String _searchQuery = '';
  String _filterCategory = 'All';
  String _filterMood = 'All';
  bool _filterFavoritesOnly = false;
  int? _filterYear;
  bool _sortNewestFirst = true;

  String get searchQuery => _searchQuery;
  String get filterCategory => _filterCategory;
  String get filterMood => _filterMood;
  bool get filterFavoritesOnly => _filterFavoritesOnly;
  int? get filterYear => _filterYear;
  bool get sortNewestFirst => _sortNewestFirst;
  
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
  
  void setFilterCategory(String category) {
    _filterCategory = category;
    notifyListeners();
  }
  
  void setFilterMood(String mood) {
    _filterMood = mood;
    notifyListeners();
  }
  
  void setFilterFavoritesOnly(bool value) {
    _filterFavoritesOnly = value;
    notifyListeners();
  }
  
  void setFilterYear(int? year) {
    _filterYear = year;
    notifyListeners();
  }
  
  void setSortNewestFirst(bool value) {
    _sortNewestFirst = value;
    notifyListeners();
  }
  
  void clearFilters() {
    _searchQuery = '';
    _filterCategory = 'All';
    _filterMood = 'All';
    _filterFavoritesOnly = false;
    _filterYear = null;
    notifyListeners();
  }

  bool get hasActiveFilters => _searchQuery.isNotEmpty || 
      _filterCategory != 'All' || 
      _filterMood != 'All' || 
      _filterFavoritesOnly || 
      _filterYear != null;

  List<int> get availableYears {
    final years = _memories.map((m) => m.date.year).toSet().toList();
    years.sort((a, b) => b.compareTo(a));
    return years;
  }

  List<Memory> get filteredMemories {
    var result = _memories.where((m) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!m.title.toLowerCase().contains(q) &&
            !m.description.toLowerCase().contains(q) &&
            !(m.locationName != null && m.locationName!.toLowerCase().contains(q))) {
          return false;
        }
      }
      if (_filterCategory != 'All' && m.category != _filterCategory) return false;
      if (_filterMood != 'All' && m.mood != _filterMood) return false;
      if (_filterFavoritesOnly && !m.isFavorite) return false;
      if (_filterYear != null && m.date.year != _filterYear) return false;
      return true;
    }).toList();

    result.sort((a, b) {
      if (_sortNewestFirst) {
        return b.date.compareTo(a.date);
      } else {
        return a.date.compareTo(b.date);
      }
    });

    return result;
  }

  Future<void> loadMemories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _memories = await _repository.getAll();
      await _updatePhotoStats();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMemory(Memory memory) async {
    try {
      final id = await _repository.insert(memory);
      final newMemory = memory.copyWith(id: id);
      _memories.insert(0, newMemory);
      _memories.sort((a, b) => b.date.compareTo(a.date));
      await _updatePhotoStats();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addMemoryWithPhotos(Memory memory, List<File> photos) async {
    try {
      final id = await _repository.insert(memory);
      final newMemory = memory.copyWith(id: id);
      
      for (var photoFile in photos) {
        await addPhotoToMemory(id, photoFile);
      }

      _memories.insert(0, newMemory);
      _memories.sort((a, b) => b.date.compareTo(a.date));
      await _updatePhotoStats();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateMemory(Memory memory) async {
    if (memory.id == null) return;
    try {
      await _repository.update(memory);
      final index = _memories.indexWhere((m) => m.id == memory.id);
      if (index != -1) {
        _memories[index] = memory;
        _memories.sort((a, b) => b.date.compareTo(a.date));
        await _updatePhotoStats();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateMemoryWithPhotos(Memory memory, List<File> newPhotos, List<MemoryPhoto> photosToDelete) async {
    if (memory.id == null) return;
    try {
      await _repository.update(memory);
      
      for (var photo in photosToDelete) {
        await deletePhoto(photo);
      }
      
      for (var photoFile in newPhotos) {
        await addPhotoToMemory(memory.id!, photoFile);
      }

      final index = _memories.indexWhere((m) => m.id == memory.id);
      if (index != -1) {
        _memories[index] = memory;
        _memories.sort((a, b) => b.date.compareTo(a.date));
        await _updatePhotoStats();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteMemory(int id) async {
    try {
      final photos = await _repository.getPhotosForMemory(id);
      for (var photo in photos) {
        final file = File(photo.imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      await _repository.delete(id);
      _memories.removeWhere((m) => m.id == id);
      await _updatePhotoStats();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(int id) async {
    final index = _memories.indexWhere((m) => m.id == id);
    if (index != -1) {
      final memory = _memories[index];
      final updatedMemory = memory.copyWith(isFavorite: !memory.isFavorite, updatedAt: DateTime.now());
      try {
        await _repository.update(updatedMemory);
        _memories[index] = updatedMemory;
        notifyListeners();
      } catch (e) {
        _error = e.toString();
        notifyListeners();
      }
    }
  }

  Future<void> clearAll() async {
    try {
      await _repository.deleteAll();
      _memories.clear();
      await _updatePhotoStats();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // --- Photo Operations ---

  Future<List<MemoryPhoto>> getPhotosForMemory(int memoryId) async {
    try {
      return await _repository.getPhotosForMemory(memoryId);
    } catch (e) {
      debugPrint('Error getting photos: $e');
      return [];
    }
  }

  Future<MemoryPhoto?> addPhotoToMemory(int memoryId, File imageFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(imageFile.path)}';
      final savedImage = await imageFile.copy('${appDir.path}/$fileName');
      
      final photo = MemoryPhoto(
        memoryId: memoryId,
        imagePath: savedImage.path,
        createdAt: DateTime.now(),
      );
      final id = await _repository.addPhoto(photo);
      await _updatePhotoStats();
      return MemoryPhoto(
        id: id,
        memoryId: memoryId,
        imagePath: savedImage.path,
        createdAt: photo.createdAt,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> deletePhoto(MemoryPhoto photo) async {
    try {
      if (photo.id != null) {
        await _repository.deletePhoto(photo.id!);
        final file = File(photo.imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      await _updatePhotoStats();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
