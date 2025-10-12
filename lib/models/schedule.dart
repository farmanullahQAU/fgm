import 'package:fmac/models/user.dart';

class Schedule {
  final String? id;
  final String title;
  final String? description;
  final DateTime date;
  final String time;
  final String googleMapLink;
  final User createdBy; // Changed from String to User
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Schedule({
    this.id,
    required this.title,
    this.description,
    required this.date,
    required this.time,
    required this.googleMapLink,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      googleMapLink: json['googleMapLink'] as String,
      createdBy: User.fromJson(
        json['createdBy'] as Map<String, dynamic>,
      ), // Parse createdBy as User
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
      if (description != null) 'description': description,
      'date': date.toIso8601String(),
      'time': time,
      'googleMapLink': googleMapLink,
      'createdBy': createdBy.toJson(), // Serialize createdBy as User JSON
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}
