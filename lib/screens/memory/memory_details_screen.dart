import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:personal_memory_map/models/memory.dart';
import 'package:personal_memory_map/models/memory_photo.dart';
import 'package:personal_memory_map/providers/memory_provider.dart';
import 'package:personal_memory_map/screens/memory/memory_form_screen.dart';

class MemoryDetailsScreen extends StatelessWidget {
  final Memory memory;

  const MemoryDetailsScreen({super.key, required this.memory});

  void _confirmDelete(BuildContext context, MemoryProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Delete this journal entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // close dialog
              if (memory.id != null) {
                await provider.deleteMemory(memory.id!);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Entry deleted successfully')),
                  );
                  Navigator.pop(context); // return to previous screen
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MemoryProvider>(
      builder: (context, provider, child) {
        // Find the latest version of the memory in case it was updated
        final currentMemory = provider.memories.firstWhere(
          (m) => m.id == memory.id,
          orElse: () => memory,
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('Journal Entry'),
            actions: [
              IconButton(
                icon: Icon(currentMemory.isFavorite ? Icons.star : Icons.star_border),
                color: currentMemory.isFavorite ? Colors.orange : null,
                onPressed: () {
                  if (currentMemory.id != null) {
                    provider.toggleFavorite(currentMemory.id!);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MemoryFormScreen(memory: currentMemory),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDelete(context, provider),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Date'),
                Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('d MMMM yyyy').format(currentMemory.date),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                _buildSectionHeader('Location'),
                if (currentMemory.locationName != null && currentMemory.locationName!.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          currentMemory.locationName!,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  )
                else
                  const Text('No location added.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                const SizedBox(height: 24),

                _buildSectionHeader('Title'),
                Text(
                  '"${currentMemory.title}"',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),

                _buildSectionHeader('Description'),
                Text(
                  currentMemory.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader('Mood'),
                          Row(
                            children: [
                              const Text('🎭 ', style: TextStyle(fontSize: 18)),
                              Text(currentMemory.mood, style: const TextStyle(fontSize: 18)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader('Category'),
                          Row(
                            children: [
                              const Text('📁 ', style: TextStyle(fontSize: 18)),
                              Text(currentMemory.category, style: const TextStyle(fontSize: 18)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                _buildSectionHeader('Photos'),
                if (currentMemory.id != null)
                  FutureBuilder<List<MemoryPhoto>>(
                    future: provider.getPhotosForMemory(currentMemory.id!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                         return const Center(child: CircularProgressIndicator());
                      }
                      
                      final photos = snapshot.data ?? [];
                      
                      if (photos.isEmpty) {
                        return const Text('No photos added yet.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
                      }

                      return SizedBox(
                        height: 250,
                        child: PageView.builder(
                          itemCount: photos.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                                image: DecorationImage(
                                  image: FileImage(File(photos[index].imagePath)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  if (photos.length > 1)
                                    Positioned(
                                      bottom: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${index + 1}/${photos.length}',
                                          style: const TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
