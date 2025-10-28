import 'match.dart';

class CourtDetails {
  final int mat;
  final List<Match> liveMatches;
  final List<Match> upcomingMatches;

  CourtDetails({
    required this.mat,
    required this.liveMatches,
    required this.upcomingMatches,
  });

  factory CourtDetails.fromJson(Map<String, dynamic> json) {
    return CourtDetails(
      mat: json['mat'] as int,
      liveMatches: (json['liveMatches'] as List<dynamic>)
          .map((e) => Match.fromJson(e as Map<String, dynamic>))
          .toList(),
      upcomingMatches: (json['upcomingMatches'] as List<dynamic>)
          .map((e) => Match.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mat': mat,
      'liveMatches': liveMatches.map((e) => e.toJson()).toList(),
      'upcomingMatches': upcomingMatches.map((e) => e.toJson()).toList(),
    };
  }
}

