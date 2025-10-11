class NewsFeed {
  final String? id;
  final String title;
  final String description;
  final String? image; // Made nullable for safety
  final Map<String, dynamic>? createdBy; // Changed to Map to match backend
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NewsFeed({
    this.id,
    required this.title,
    required this.description,
    this.image,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory NewsFeed.fromJson(dynamic json) {
    return NewsFeed(
      id: json['_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      image: json['image'] as String?,
      createdBy: json['createdBy'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'title': title,
      'description': description,
      if (image != null) 'image': image,
      if (createdBy != null) 'createdBy': createdBy,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}
