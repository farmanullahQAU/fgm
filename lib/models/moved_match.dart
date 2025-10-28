class MovedMatch {
  final String id;
  final String originalMatchNumber;
  final String newMatchNumber;
  final String matchNumber;
  final String category;
  final String round;
  final String originalCourtNumber;
  final String newCourtNumber;
  final String originalStartTime;
  final String newStartTime;
  final String movedAt;
  final String reason;
  final Competitor homeCompetitor;
  final Competitor awayCompetitor;

  MovedMatch({
    required this.id,
    required this.originalMatchNumber,
    required this.newMatchNumber,
    required this.matchNumber,
    required this.category,
    required this.round,
    required this.originalCourtNumber,
    required this.newCourtNumber,
    required this.originalStartTime,
    required this.newStartTime,
    required this.movedAt,
    required this.reason,
    required this.homeCompetitor,
    required this.awayCompetitor,
  });

  factory MovedMatch.fromJson(Map<String, dynamic> json) {
    return MovedMatch(
      id: json['id'] as String,
      originalMatchNumber: json['originalMatchNumber'] ?? "",
      newMatchNumber: json['newMatchNumber'] ?? "",
      matchNumber: json['matchNumber'] ?? "",
      category: json['category'] ?? "",
      round: json['round']?.toString() ?? "",
      originalCourtNumber: json['originalCourtNumber'] ?? "",
      newCourtNumber: json['newCourtNumber'] ?? "",
      originalStartTime: json['originalStartTime'] ?? "",
      newStartTime: json['newStartTime'] ?? "",
      movedAt: json['movedAt'] ?? "",
      reason: json['reason'] ?? "",
      homeCompetitor: Competitor.fromJson(
        json['homeCompetitor'] as Map<String, dynamic>,
      ),
      awayCompetitor: Competitor.fromJson(
        json['awayCompetitor'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalMatchNumber': originalMatchNumber,
      'newMatchNumber': newMatchNumber,
      'matchNumber': matchNumber,
      'category': category,
      'round': round,
      'originalCourtNumber': originalCourtNumber,
      'newCourtNumber': newCourtNumber,
      'originalStartTime': originalStartTime,
      'newStartTime': newStartTime,
      'movedAt': movedAt,
      'reason': reason,
      'homeCompetitor': homeCompetitor.toJson(),
      'awayCompetitor': awayCompetitor.toJson(),
    };
  }
}

class Competitor {
  final String id;
  final String name;
  final String country;
  final String countryInfo;

  Competitor({
    required this.id,
    required this.name,
    required this.country,
    required this.countryInfo,
  });

  factory Competitor.fromJson(Map<String, dynamic> json) {
    return Competitor(
      id: json['id'] ?? "",
      name: json['name'] ?? "",
      country: json['country'],
      countryInfo: json['countryInfo'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'countryInfo': countryInfo,
    };
  }
}
