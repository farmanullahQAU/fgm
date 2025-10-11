class AppHeaderLogo {
  final String? id;
  final String position;
  final String imageUrl;
  final String? altText;
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppHeaderLogo({
    this.id,
    required this.position,
    required this.imageUrl,
    this.altText,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory AppHeaderLogo.fromJson(Map<String, dynamic> json) {
    return AppHeaderLogo(
      id: json['_id'] as String?,
      position: json['position'] as String,
      imageUrl: json['imageUrl'] as String,
      altText: json['altText'] as String?,
      createdBy: json['createdBy'] as String,
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
      'position': position,
      'imageUrl': imageUrl,
      if (altText != null) 'altText': altText,
      'createdBy': createdBy,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}
