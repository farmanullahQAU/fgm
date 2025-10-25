import 'package:flutter/widgets.dart';

class Event {
  final String id;
  final String name;
  final String description;
  final String location;
  final String image;
  final String status;
  // final String category;
  final String startDate;
  final String endDate;
  final List<String> eventDates;

  final Pricing pricing;
  // final User createdBy;
  // final User updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  // final String fullTitle;
  // final String formattedDateTime;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.image,
    required this.status,
    // required this.category,
    required this.eventDates,
    required this.startDate,
    required this.endDate,
    required this.pricing,
    // required this.createdBy,
    // required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
    // required this.fullTitle,
    // required this.formattedDateTime,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    debugPrint('Event JSON: $json'); // Debugging line
    return Event(
      id: json['_id'] as String,
      name: json['name'] ?? "",
      description: json['description'] ?? "...",
      location: json['location'] ?? "",
      image: json['image'] ?? "",
      status: json['status'] ?? "...",
      // category: json['category'] as String,
      eventDates: List<String>.from(json['eventDates']),
      startDate: json['startDate'] ?? "",
      endDate: json['endDate'] ?? "",
      pricing: Pricing.fromJson(json['ticketPrice'] as Map<String, dynamic>),
      // createdBy: User.fromJson(json['createdBy'] as Map<String, dynamic>),
      // updatedBy: User.fromJson(json['updatedBy'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      // fullTitle: json['fullTitle'] as String,
      // formattedDateTime: json['formattedDateTime'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'location': location,
      'image': image,
      'status': status,
      // 'category': category,
      'eventDates': eventDates,
      'startDate': startDate,
      'endDate': endDate,
      'pricing': pricing.toJson(),
      // 'createdBy': createdBy.toJson(),
      // 'updatedBy': updatedBy.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      // 'fullTitle': fullTitle,
      // 'formattedDateTime': formattedDateTime,
    };
  }
}

class Pricing {
  final int adult;
  final int child;

  Pricing({required this.adult, required this.child});

  factory Pricing.fromJson(Map<String, dynamic> json) {
    return Pricing(adult: json['adult'] as int, child: json['child'] as int);
  }

  Map<String, dynamic> toJson() {
    return {'adult': adult, 'child': child};
  }
}
