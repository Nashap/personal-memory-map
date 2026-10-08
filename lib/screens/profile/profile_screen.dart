import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personal_memory_map/providers/theme_provider.dart';
import 'package:personal_memory_map/providers/memory_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer2<ThemeProvider, MemoryProvider>(
        builder: (context, themeProvider, memoryProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildStatistics(context, memoryProvider),
              const SizedBox(height: 24),
              if (memoryProvider.categoryCounts.isNotEmpty) ...[
                _buildCategoryBreakdown(context, memoryProvider),
                const SizedBox(height: 24),
              ],
              if (memoryProvider.yearCounts.isNotEmpty) ...[
                _buildYearActivity(context, memoryProvider),
                const SizedBox(height: 24),
              ],
              if (memoryProvider.memoriesWithLocations > 0) ...[
                _buildLocationSummary(context, memoryProvider),
                const SizedBox(height: 24),
              ],
              _buildSettings(context, themeProvider, memoryProvider),
              const SizedBox(height: 24),
              _buildAbout(context),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 40,
          child: Icon(Icons.person, size: 40),
        ),
        const SizedBox(height: 16),
        Text(
          'My Memory Journey',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Your places, moments and stories.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildStatistics(BuildContext context, MemoryProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(context, 'Total Memories', provider.totalMemories.toString(), Icons.book),
            _buildStatCard(context, 'Favorites', provider.favoriteCount.toString(), Icons.favorite, color: Colors.red),
            _buildStatCard(context, 'With Photos', provider.memoriesWithPhotosCount.toString(), Icons.photo_library),
            _buildStatCard(context, 'With Locations', provider.memoriesWithLocations.toString(), Icons.location_on, color: Colors.blue),
            _buildStatCard(context, 'Total Photos', provider.totalPhotoCount.toString(), Icons.image),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, {Color? color}) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color ?? Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(BuildContext context, MemoryProvider provider) {
    final categories = provider.categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // Sort descending

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category Breakdown',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: categories.map((entry) {
                final double percentage = entry.value / provider.totalMemories;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          entry.key,
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: percentage,
                          borderRadius: BorderRadius.circular(8),
                          minHeight: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 24,
                        child: Text(
                          entry.value.toString(),
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYearActivity(BuildContext context, MemoryProvider provider) {
    final years = provider.yearCounts.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key)); // Sort descending by year

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Year Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: years.map((entry) {
                // simple visual blocks representation
                final blocks = '█' * entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Text(
                        entry.key.toString(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          blocks,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 14,
                            letterSpacing: 2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        entry.value.toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSummary(BuildContext context, MemoryProvider provider) {
    // Find most common location
    final locationCounts = <String, int>{};
    for (var m in provider.memories) {
      if (m.locationName != null && m.locationName!.isNotEmpty) {
        locationCounts[m.locationName!] = (locationCounts[m.locationName!] ?? 0) + 1;
      }
    }
    
    String mostCommonLocation = '';
    int maxCount = 0;
    
    locationCounts.forEach((key, value) {
      if (value > maxCount) {
        maxCount = value;
        mostCommonLocation = key;
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Places',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Memories with locations'),
                    Text(
                      provider.memoriesWithLocations.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (mostCommonLocation.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Most visited'),
                      Expanded(
                        child: Text(
                          mostCommonLocation,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ]
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettings(BuildContext context, ThemeProvider themeProvider, MemoryProvider memoryProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.brightness_medium),
                title: const Text('Appearance'),
                trailing: DropdownButton<ThemeMode>(
                  value: themeProvider.themeMode,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                    DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                  ],
                  onChanged: (ThemeMode? mode) {
                    if (mode != null) {
                      themeProvider.setThemeMode(mode);
                    }
                  },
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Clear all memories', style: TextStyle(color: Colors.red)),
                onTap: () => _showClearAllDialog(context, memoryProvider),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showClearAllDialog(BuildContext context, MemoryProvider memoryProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete all memories?'),
        content: const Text('This action will permanently delete all your memories and attached photos. This cannot be undone. Are you sure you want to proceed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await memoryProvider.clearAll();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All memories cleared.')),
                );
              }
            },
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  Widget _buildAbout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personal Memory Map',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text('Version 1.0.0', style: TextStyle(color: Colors.grey)),
                SizedBox(height: 12),
                Text(
                  'A private space for keeping memories connected to meaningful moments and places.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
