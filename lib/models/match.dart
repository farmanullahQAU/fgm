class Match {
  final String id;
  final String matchNumber;
  final int mat;
  final String phase;
  final int currentRound;
  final String roundTime;
  final String status;
  final String scheduledStart;
  final String actualStart;
  final String estimatedStart;
  final MatchScore score;
  final MatchPenalties penalties;
  final MatchWarnings warnings;
  final MatchDeductions deductions;
  final MatchResult result;
  final List<RoundScore> roundScores;
  final Competitor homeCompetitor;
  final Competitor awayCompetitor;
  final MatchEvent event;

  Match({
    required this.id,
    required this.matchNumber,
    required this.mat,
    required this.phase,
    required this.currentRound,
    required this.roundTime,
    required this.status,
    required this.scheduledStart,
    required this.actualStart,
    required this.estimatedStart,
    required this.score,
    required this.penalties,
    required this.warnings,
    required this.deductions,
    required this.result,
    required this.roundScores,
    required this.homeCompetitor,
    required this.awayCompetitor,
    required this.event,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'] as String,
      matchNumber: json['matchNumber'] as String,
      mat: json['mat'] as int,
      phase: json['phase'] as String,
      currentRound: json['currentRound'] as int,
      roundTime: json['roundTime'] as String,
      status: json['status'] as String,
      scheduledStart: json['scheduledStart'] as String,
      actualStart: json['actualStart'] as String,
      estimatedStart: json['estimatedStart'] as String,
      score: MatchScore.fromJson(json['score'] as Map<String, dynamic>),
      penalties: MatchPenalties.fromJson(
        json['penalties'] as Map<String, dynamic>,
      ),
      warnings: MatchWarnings.fromJson(
        json['warnings'] as Map<String, dynamic>,
      ),
      deductions: MatchDeductions.fromJson(
        json['deductions'] as Map<String, dynamic>,
      ),
      result: MatchResult.fromJson(json['result'] as Map<String, dynamic>),
      roundScores: (json['roundScores'] as List<dynamic>)
          .map((e) => RoundScore.fromJson(e as Map<String, dynamic>))
          .toList(),
      homeCompetitor: Competitor.fromJson(
        json['homeCompetitor'] as Map<String, dynamic>,
      ),
      awayCompetitor: Competitor.fromJson(
        json['awayCompetitor'] as Map<String, dynamic>,
      ),
      event: MatchEvent.fromJson(json['event'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matchNumber': matchNumber,
      'mat': mat,
      'phase': phase,
      'currentRound': currentRound,
      'roundTime': roundTime,
      'status': status,
      'scheduledStart': scheduledStart,
      'actualStart': actualStart,
      'estimatedStart': estimatedStart,
      'score': score.toJson(),
      'penalties': penalties.toJson(),
      'warnings': warnings.toJson(),
      'deductions': deductions.toJson(),
      'result': result.toJson(),
      'roundScores': roundScores.map((e) => e.toJson()).toList(),
      'homeCompetitor': homeCompetitor.toJson(),
      'awayCompetitor': awayCompetitor.toJson(),
      'event': event.toJson(),
    };
  }
}

class MatchScore {
  final int? home;
  final int? away;

  MatchScore({required this.home, required this.away});

  factory MatchScore.fromJson(Map<String, dynamic> json) {
    return MatchScore(home: json['home'] as int?, away: json['away'] as int?);
  }

  Map<String, dynamic> toJson() {
    return {'home': home, 'away': away};
  }
}

class MatchPenalties {
  final int? home;
  final int? away;

  MatchPenalties({required this.home, required this.away});

  factory MatchPenalties.fromJson(Map<String, dynamic> json) {
    return MatchPenalties(
      home: json['home'] as int?,
      away: json['away'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'home': home, 'away': away};
  }
}

class MatchWarnings {
  final int home;
  final int away;

  MatchWarnings({required this.home, required this.away});

  factory MatchWarnings.fromJson(Map<String, dynamic> json) {
    return MatchWarnings(home: json['home'] as int, away: json['away'] as int);
  }

  Map<String, dynamic> toJson() {
    return {'home': home, 'away': away};
  }
}

class MatchDeductions {
  final int home;
  final int away;

  MatchDeductions({required this.home, required this.away});

  factory MatchDeductions.fromJson(Map<String, dynamic> json) {
    return MatchDeductions(
      home: json['home'] as int,
      away: json['away'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'home': home, 'away': away};
  }
}

class MatchResult {
  final String status;
  final String? decision;
  final String? homeType;
  final String? awayType;

  MatchResult({
    required this.status,
    this.decision,
    this.homeType,
    this.awayType,
  });

  factory MatchResult.fromJson(Map<String, dynamic> json) {
    return MatchResult(
      status: json['status'] as String,
      decision: json['decision'] as String?,
      homeType: json['homeType'] as String?,
      awayType: json['awayType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'decision': decision,
      'homeType': homeType,
      'awayType': awayType,
    };
  }
}

class RoundScore {
  final int round;
  final int home;
  final int away;

  RoundScore({required this.round, required this.home, required this.away});

  factory RoundScore.fromJson(Map<String, dynamic> json) {
    return RoundScore(
      round: json['round'] as int,
      home: json['home'] as int,
      away: json['away'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'round': round, 'home': home, 'away': away};
  }
}

class Competitor {
  final String id;
  final String name;
  final String country;
  final Map<String, dynamic>? countryInfo;
  final List<dynamic> participants;

  Competitor({
    required this.id,
    required this.name,
    required this.country,
    this.countryInfo,
    required this.participants,
  });

  factory Competitor.fromJson(Map<String, dynamic> json) {
    return Competitor(
      id: json['id'] as String,
      name: json['name'] as String,
      country: json['country'] as String,
      countryInfo: json['countryInfo'] as Map<String, dynamic>?,
      participants: json['participants'] as List<dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'countryInfo': countryInfo,
      'participants': participants,
    };
  }
}

class MatchEvent {
  final String id;
  final String name;
  final String discipline;
  final String division;
  final String gender;
  final String weightCategory;

  MatchEvent({
    required this.id,
    required this.name,
    required this.discipline,
    required this.division,
    required this.gender,
    required this.weightCategory,
  });

  factory MatchEvent.fromJson(Map<String, dynamic> json) {
    return MatchEvent(
      id: json['id'] as String,
      name: json['name'] as String,
      discipline: json['discipline'] as String,
      division: json['division'] as String,
      gender: json['gender'] as String,
      weightCategory: json['weightCategory'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'discipline': discipline,
      'division': division,
      'gender': gender,
      'weightCategory': weightCategory,
    };
  }
}
