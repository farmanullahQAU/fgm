import 'user.dart';

class DrawList {
  final String? id;
  final String title;
  final String description;
  final DateTime date;
  final String time;
  final String? pdfUrl;
  final User createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  DrawList({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    this.pdfUrl,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DrawList.fromJson(Map<String, dynamic> json) {
    return DrawList(
      id: json['_id'] ?? json['id'],
      title: json['title'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      pdfUrl: json['pdfUrl'],
      createdBy: User.fromJson(json['createdBy']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'time': time,
      if (pdfUrl != null) 'pdfUrl': pdfUrl,
      'createdBy': createdBy.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
