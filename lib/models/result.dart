class Result {
  final String? id;
  final String title;
  final String? description;
  final DateTime date;
  final String time;
  final String pdfUrl;
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Result({
    this.id,
    required this.title,
    this.description,
    required this.date,
    required this.time,
    required this.pdfUrl,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      id: json['_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      pdfUrl: json['pdfUrl'] as String,
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
      'title': title,
      if (description != null) 'description': description,
      'date': date.toIso8601String(),
      'time': time,
      'pdfUrl': pdfUrl,
      'createdBy': createdBy,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}
