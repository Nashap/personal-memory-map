

class Memory {
  final int? id;
  final String title;
  final String description;
  final DateTime date;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final String category;
  final String mood;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  Memory({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    this.latitude,
    this.longitude,
    this.locationName,
    required this.category,
    required this.mood,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Memory copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? date,
    double? latitude,
    double? longitude,
    String? locationName,
    String? category,
    String? mood,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Memory(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      category: category ?? this.category,
      mood: mood ?? this.mood,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'category': category,
      'mood': mood,
      'isFavorite': isFavorite ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Memory.fromMap(Map<String, dynamic> map) {
    return Memory(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      date: DateTime.parse(map['date'] as String),
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      locationName: map['locationName'] as String?,
      category: map['category'] as String,
      mood: map['mood'] as String,
      isFavorite: (map['isFavorite'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
