import 'package:fmac/models/user.dart';

class Carousel {
  final String? id;
  final String? image;
  final int order;
  final User? createdBy; // ObjectId as string
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Carousel({
    this.id,
    this.image,
    this.order = 0,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Carousel.fromJson(Map<String, dynamic> json) {
    return Carousel(
      id: json['_id'] as String?,
      image: json['image'] as String?,
      order: json['order'] as int? ?? 0,
      createdBy: User.fromJson(json['createdBy'] as Map<String, dynamic>),
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
      if (image != null) 'image': image,
      'order': order,
      if (createdBy != null) 'createdBy': createdBy?.toJson(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}
