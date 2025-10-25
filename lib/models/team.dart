class Team {
  final String? id;
  final String teamId;
  final TeamAttributes attributes;
  final int athleteCount;
  final int officialCount;
  final Map<String, dynamic> country;
  final int totalParticipants;

  Team({
    this.id,
    required this.teamId,
    required this.attributes,
    required this.athleteCount,
    required this.officialCount,
    required this.country,
    required this.totalParticipants,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['_id'] as String?,
      teamId: json['id'] as String,
      attributes: TeamAttributes.fromJson(
        json['attributes'] as Map<String, dynamic>,
      ),
      athleteCount: json['athleteCount'] as int,
      officialCount: json['officialCount'] as int,
      country: json['country'] as Map<String, dynamic>? ?? {},
      totalParticipants: json['totalParticipants'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'id': teamId,
      'attributes': attributes.toJson(),
      'athleteCount': athleteCount,
      'officialCount': officialCount,
      'country': country,
      'totalParticipants': totalParticipants,
    };
  }
}

class TeamAttributes {
  final String name;
  final String country;

  TeamAttributes({required this.name, required this.country});

  factory TeamAttributes.fromJson(Map<String, dynamic> json) {
    return TeamAttributes(
      name: json['name'] as String,
      country: json['country'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'country': country};
  }
}
