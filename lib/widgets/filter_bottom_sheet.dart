import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personal_memory_map/providers/memory_provider.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MemoryProvider>();
    final years = provider.availableYears;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filters', style: Theme.of(context).textTheme.headlineSmall),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              
              const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['All', 'College', 'Work', 'Travel', 'Family', 'Friends', 'Achievement', 'Special', 'Other'].map((category) {
                  return ChoiceChip(
                    label: Text(category),
                    selected: provider.filterCategory == category,
                    onSelected: (selected) {
                      if (selected) provider.setFilterCategory(category);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              const Text('Mood', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['All', 'Happy', 'Loved', 'Excited', 'Peaceful', 'Emotional', 'Sad', 'Proud'].map((mood) {
                  return ChoiceChip(
                    label: Text(mood),
                    selected: provider.filterMood == mood,
                    onSelected: (selected) {
                      if (selected) provider.setFilterMood(mood);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              const Text('Favorites', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Favorites only'),
                value: provider.filterFavoritesOnly,
                onChanged: (val) => provider.setFilterFavoritesOnly(val),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),

              if (years.isNotEmpty) ...[
                const Text('Year', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: provider.filterYear == null,
                      onSelected: (selected) {
                        if (selected) provider.setFilterYear(null);
                      },
                    ),
                    ...years.map((year) {
                      return ChoiceChip(
                        label: Text(year.toString()),
                        selected: provider.filterYear == year,
                        onSelected: (selected) {
                          if (selected) provider.setFilterYear(year);
                        },
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Apply'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
