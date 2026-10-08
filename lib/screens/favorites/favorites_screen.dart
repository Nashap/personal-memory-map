import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personal_memory_map/models/memory_photo.dart';
import 'package:personal_memory_map/providers/memory_provider.dart';
import 'package:personal_memory_map/screens/memory/memory_details_screen.dart';
import 'package:personal_memory_map/widgets/search_filter_bar.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<MemoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final favorites = provider.filteredMemories.where((m) => m.isFavorite).toList();
          
          return Column(
            children: [
              const SearchFilterBar(),
              Expanded(
                child: favorites.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite_outline,
                              size: 80,
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              provider.hasActiveFilters ? 'No favorites match filters' : 'No favorites yet',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              provider.hasActiveFilters 
                                  ? 'Try clearing filters to see your favorites.'
                                  : 'Your favorite memories will appear here.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: favorites.length,
                        itemBuilder: (context, index) {
                          final memory = favorites[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: FutureBuilder<List<MemoryPhoto>>(
                                future: provider.getPhotosForMemory(memory.id ?? -1),
                                builder: (context, snapshot) {
                                  final photos = snapshot.data ?? [];
                                  if (photos.isNotEmpty) {
                                    return CircleAvatar(
                                      backgroundImage: FileImage(File(photos.first.imagePath)),
                                      onBackgroundImageError: (error, stackTrace) {},
                                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                    );
                                  }
                                  return CircleAvatar(
                                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                    child: Icon(
                                      Icons.favorite,
                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    ),
                                  );
                                },
                              ),
                              title: Text(memory.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(memory.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                                  if (memory.locationName != null && memory.locationName!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              memory.locationName!,
                                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.favorite, color: Colors.red),
                                onPressed: () {
                                  if (memory.id != null) {
                                    provider.toggleFavorite(memory.id!);
                                  }
                                },
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MemoryDetailsScreen(memory: memory),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
