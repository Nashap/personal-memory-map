class MemoryPhoto {
  final int? id;
  final int memoryId;
  final String imagePath;
  final DateTime createdAt;

  MemoryPhoto({
    this.id,
    required this.memoryId,
    required this.imagePath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'memoryId': memoryId,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory MemoryPhoto.fromMap(Map<String, dynamic> map) {
    return MemoryPhoto(
      id: map['id'] as int?,
      memoryId: map['memoryId'] as int,
      imagePath: map['imagePath'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
