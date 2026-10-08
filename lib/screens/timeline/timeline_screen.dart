import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personal_memory_map/models/memory_photo.dart';
import 'package:personal_memory_map/providers/memory_provider.dart';
import 'package:personal_memory_map/screens/memory/memory_details_screen.dart';
import 'package:personal_memory_map/screens/memory/memory_form_screen.dart';
import 'package:personal_memory_map/widgets/search_filter_bar.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<MemoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final memories = provider.filteredMemories;
          
          return Column(
            children: [
              const SearchFilterBar(),
              Expanded(
                child: memories.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timeline,
                              size: 80,
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No memories found',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              provider.hasActiveFilters 
                                  ? 'Try clearing your filters to see more results.'
                                  : 'Your memory timeline will appear here.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: memories.length,
                        itemBuilder: (context, index) {
                          final memory = memories[index];
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
                                      Icons.place,
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
                              trailing: Text(
                                memory.category,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MemoryFormScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Entry'),
        elevation: 4,
      ),
    );
  }
}
