import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personal_memory_map/providers/memory_provider.dart';
import 'package:personal_memory_map/widgets/filter_bottom_sheet.dart';

class SearchFilterBar extends StatelessWidget {
  const SearchFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MemoryProvider>();
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: provider.searchQuery)
                    ..selection = TextSelection.collapsed(offset: provider.searchQuery.length),
                  decoration: InputDecoration(
                    hintText: 'Search memories...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: provider.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => provider.setSearchQuery(''),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (val) => provider.setSearchQuery(val),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonalIcon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => const FilterBottomSheet(),
                  );
                },
                icon: const Icon(Icons.filter_list),
                label: const Text('Filters'),
              ),
            ],
          ),
        ),
        if (provider.hasActiveFilters)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (provider.filterCategory != 'All')
                  InputChip(
                    label: Text(provider.filterCategory),
                    onDeleted: () => provider.setFilterCategory('All'),
                  ),
                if (provider.filterMood != 'All')
                  InputChip(
                    label: Text(provider.filterMood),
                    onDeleted: () => provider.setFilterMood('All'),
                  ),
                if (provider.filterYear != null)
                  InputChip(
                    label: Text(provider.filterYear.toString()),
                    onDeleted: () => provider.setFilterYear(null),
                  ),
                if (provider.filterFavoritesOnly)
                  InputChip(
                    label: const Text('❤️ Favorites'),
                    onDeleted: () => provider.setFilterFavoritesOnly(false),
                  ),
                TextButton(
                  onPressed: () => provider.clearFilters(),
                  child: const Text('Clear Filters'),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                provider.hasActiveFilters 
                  ? '${provider.filteredMemories.length} memories found'
                  : '${provider.memories.length} memories',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Row(
                children: [
                  const Text('Sort: '),
                  DropdownButton<bool>(
                    value: provider.sortNewestFirst,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: true, child: Text('Newest first')),
                      DropdownMenuItem(value: false, child: Text('Oldest first')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        provider.setSortNewestFirst(val);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
