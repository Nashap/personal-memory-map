import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:personal_memory_map/models/memory.dart';
import 'package:personal_memory_map/models/memory_photo.dart';
import 'package:personal_memory_map/providers/memory_provider.dart';
import 'package:personal_memory_map/services/location_service.dart';

class MemoryFormScreen extends StatefulWidget {
  final Memory? memory;

  const MemoryFormScreen({super.key, this.memory});

  @override
  State<MemoryFormScreen> createState() => _MemoryFormScreenState();
}

class _MemoryFormScreenState extends State<MemoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late DateTime _selectedDate;
  late String _selectedCategory;
  late String _selectedMood;
  late bool _isFavorite;
  
  double? _latitude;
  double? _longitude;
  bool _isLoadingLocation = false;
  
  final ImagePicker _picker = ImagePicker();
  final List<File> _newPhotos = [];
  List<MemoryPhoto> _existingPhotos = [];
  final List<MemoryPhoto> _photosToDelete = [];
  bool _isLoadingPhotos = false;

  final List<String> _categories = [
    'College',
    'Work',
    'Travel',
    'Family',
    'Friends',
    'Achievement',
    'Special',
    'Other'
  ];

  final List<String> _moods = [
    'Happy',
    'Loved',
    'Excited',
    'Peaceful',
    'Emotional',
    'Sad',
    'Proud'
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.memory?.title ?? '');
    _descriptionController = TextEditingController(text: widget.memory?.description ?? '');
    _locationController = TextEditingController(text: widget.memory?.locationName ?? '');
    _selectedDate = widget.memory?.date ?? DateTime.now();
    
    _selectedCategory = widget.memory?.category ?? _categories.first;
    if (!_categories.contains(_selectedCategory)) {
      _selectedCategory = _categories.first;
    }

    _selectedMood = widget.memory?.mood ?? _moods.first;
    if (!_moods.contains(_selectedMood)) {
      _selectedMood = _moods.first;
    }

    _isFavorite = widget.memory?.isFavorite ?? false;

    _latitude = widget.memory?.latitude;
    _longitude = widget.memory?.longitude;

    if (widget.memory != null && widget.memory!.id != null) {
      _loadExistingPhotos();
    }
  }

  Future<void> _loadExistingPhotos() async {
    setState(() { _isLoadingPhotos = true; });
    // We need to fetch photos after the first frame so we can access the provider
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<MemoryProvider>(context, listen: false);
      final photos = await provider.getPhotosForMemory(widget.memory!.id!);
      if (mounted) {
        setState(() {
          _existingPhotos = photos;
          _isLoadingPhotos = false;
        });
      }
    });
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _newPhotos.addAll(pickedFiles.map((file) => File(file.path)));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick images: $e')),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() { _isLoadingLocation = true; });
    try {
      final locationService = LocationService();
      final position = await locationService.getCurrentLocation();
      if (position != null) {
        final address = await locationService.getAddressFromCoordinates(position.latitude, position.longitude);
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _locationController.text = address ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoadingLocation = false; });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveMemory() async {
    if (_formKey.currentState!.validate()) {
      final isNew = widget.memory == null;
      
      final memory = Memory(
        id: widget.memory?.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _selectedDate,
        category: _selectedCategory,
        mood: _selectedMood,
        isFavorite: _isFavorite,
        createdAt: widget.memory?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        latitude: _latitude,
        longitude: _longitude,
        locationName: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
      );

      final provider = Provider.of<MemoryProvider>(context, listen: false);
      
      if (isNew) {
        await provider.addMemoryWithPhotos(memory, _newPhotos);
      } else {
        await provider.updateMemoryWithPhotos(memory, _newPhotos, _photosToDelete);
      }

      if (!mounted) return;

      if (provider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${provider.error}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isNew ? 'Memory created successfully' : 'Memory updated successfully')),
        );
        Navigator.pop(context);
      }
    }
  }

  Widget _buildSectionHeader(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
          ],
        ],
      ),
    );
  }

  Widget _buildPhotoPreview(File file, VoidCallback onRemove) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(right: 12.0, top: 8.0),
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            image: DecorationImage(
              image: FileImage(file),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              padding: const EdgeInsets.all(4.0),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.memory == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? 'Add Memory' : 'Edit Memory', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          children: [
            _buildSectionHeader('Date'),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('d MMMM yyyy').format(_selectedDate),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            
            _buildSectionHeader('Location', subtitle: 'Where did this memory happen?'),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.location_on),
                hintText: 'Enter location... (e.g. Kothamangalam, Kerala)',
                filled: true,
                fillColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.02),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: _isLoadingLocation
                ? const Padding(padding: EdgeInsets.all(12.0), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)))
                : TextButton.icon(
                    onPressed: _getCurrentLocation,
                    icon: const Icon(Icons.my_location, size: 16),
                    label: const Text('Use Current Location'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
            ),
            
            _buildSectionHeader('Title'),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Give your memory a title',
                filled: true,
                fillColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.02),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            
            _buildSectionHeader('Description'),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Write about this memory...',
                filled: true,
                fillColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.02),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
                ),
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            
            _buildSectionHeader('Category'),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : null,
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            
            _buildSectionHeader('Mood'),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _moods.map((mood) {
                final isSelected = _selectedMood == mood;
                return ChoiceChip(
                  label: Text(mood),
                  selected: isSelected,
                  selectedColor: Theme.of(context).colorScheme.secondaryContainer,
                  labelStyle: TextStyle(
                    color: isSelected ? Theme.of(context).colorScheme.onSecondaryContainer : null,
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedMood = mood;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            
            Padding(
              padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Photos', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                  TextButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Add Photos'),
                  ),
                ],
              ),
            ),
            
            if (_isLoadingPhotos)
              const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
            else if (_existingPhotos.isEmpty && _newPhotos.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3), style: BorderStyle.solid),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.image_outlined, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('No photos added yet', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            else
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._existingPhotos.map((photo) => _buildPhotoPreview(File(photo.imagePath), () {
                      setState(() {
                        _existingPhotos.remove(photo);
                        _photosToDelete.add(photo);
                      });
                    })),
                    ..._newPhotos.asMap().entries.map((entry) => _buildPhotoPreview(entry.value, () {
                      setState(() {
                        _newPhotos.removeAt(entry.key);
                      });
                    })),
                  ],
                ),
              ),
            
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: _isFavorite ? Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.3) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _isFavorite ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
              ),
              child: SwitchListTile(
                title: const Text('Add to Favorites', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Highlight this memory in your journal'),
                secondary: Icon(
                  _isFavorite ? Icons.star : Icons.star_border,
                  color: _isFavorite ? Colors.amber : Colors.grey,
                  size: 32,
                ),
                value: _isFavorite,
                onChanged: (value) {
                  setState(() {
                    _isFavorite = value;
                  });
                },
              ),
            ),
            
            const SizedBox(height: 40),
            FilledButton.icon(
              onPressed: _saveMemory,
              icon: const Icon(Icons.check),
              label: Text(isNew ? 'Save Memory' : 'Update Memory', style: const TextStyle(fontSize: 16)),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
