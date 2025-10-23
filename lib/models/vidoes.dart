import 'package:intl/intl.dart';

class Video {
  final String id;
  final String title;
  final String description;
  final String youtubeUrl;
  final String type;
  final String? event;
  final String duration; // ✅ FIXED: was int?
  final bool isLive;
  final int viewCount;
  final DateTime publishedAt;
  final int order;
  final bool isActive;
  final String videoId;
  final String thumbnail;

  Video({
    required this.id,
    required this.title,
    required this.description,
    required this.youtubeUrl,
    required this.type,
    this.event,
    required this.duration,
    required this.isLive,
    required this.viewCount,
    required this.publishedAt,
    required this.order,
    required this.isActive,
    required this.videoId,
    required this.thumbnail,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      youtubeUrl: json['youtubeUrl'],
      type: json['type'],
      event: json['event'], // nullable
      duration: json['duration'], // ✅ String
      isLive: json['isLive'],
      viewCount: json['viewCount'] ?? 0,
      publishedAt: DateTime.parse(json['publishedAt']),
      order: json['order'] ?? 0,
      isActive: json['isActive'],
      videoId: json['videoId'],
      thumbnail: json['thumbnail'],
    );
  }

  String getFormattedDate() {
    try {
      return DateFormat('dd MMM yyyy').format(publishedAt);
    } catch (e) {
      return publishedAt.toString();
    }
  }
}
