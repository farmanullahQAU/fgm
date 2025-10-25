class Athlete {
  final String? id;
  final String athleteId;
  final AthleteAttributes attributes;
  final List<MatchProgression> matchProgression;
  final List<MatchHistory> matchHistory;
  final int totalWins;
  final Map<String, dynamic> country;
  final int rank;
  final int seed;
  final String organizationName;

  Athlete({
    this.id,
    required this.athleteId,
    required this.attributes,
    required this.matchProgression,
    required this.matchHistory,
    required this.totalWins,
    required this.country,
    required this.rank,
    required this.seed,
    required this.organizationName,
  });

  factory Athlete.fromJson(Map<String, dynamic> json) {
    return Athlete(
      id: json['_id'] as String?,
      athleteId: json['id'] as String,
      attributes: AthleteAttributes.fromJson(
        json['attributes'] as Map<String, dynamic>,
      ),
      matchProgression:
          (json['matchProgression'] as List<dynamic>?)
              ?.map((e) => MatchProgression.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      matchHistory:
          (json['matchHistory'] as List<dynamic>?)
              ?.map((e) => MatchHistory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalWins: json['totalWins'] as int,
      country: json['country'] as Map<String, dynamic>? ?? {},
      rank: json['rank'] as int,
      seed: json['seed'] as int,
      organizationName: json['organizationName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'id': athleteId,
      'attributes': attributes.toJson(),
      'matchProgression': matchProgression.map((e) => e.toJson()).toList(),
      'matchHistory': matchHistory.map((e) => e.toJson()).toList(),
      'totalWins': totalWins,
      'country': country,
      'rank': rank,
      'seed': seed,
      'organizationName': organizationName,
    };
  }
}

class AthleteAttributes {
  final String licenseNumber;
  final String givenName;
  final String familyName;
  final String printName;
  final String gender;
  final String birthDate;
  final String country;

  AthleteAttributes({
    required this.licenseNumber,
    required this.givenName,
    required this.familyName,
    required this.printName,
    required this.gender,
    required this.birthDate,
    required this.country,
  });

  factory AthleteAttributes.fromJson(Map<String, dynamic> json) {
    return AthleteAttributes(
      licenseNumber: json['licenseNumber'] as String,
      givenName: json['givenName'] as String,
      familyName: json['familyName'] as String,
      printName: json['printName'] as String,
      gender: json['gender'] as String,
      birthDate: json['birthDate'] as String,
      country: json['country'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'licenseNumber': licenseNumber,
      'givenName': givenName,
      'familyName': familyName,
      'printName': printName,
      'gender': gender,
      'birthDate': birthDate,
      'country': country,
    };
  }
}

class MatchProgression {
  final String? id;
  final Event event;
  final String phase;
  final String? positionReference;
  final int round;
  final String number;
  final int? score;
  final int? opponentScore;
  final bool isWinner;
  final String status;
  final String scheduledStart;
  final String actualStart;
  final int mat;
  final int? penalties;
  final int? opponentPenalties;
  final String competitorPosition;

  MatchProgression({
    this.id,
    required this.event,
    required this.phase,
    this.positionReference,
    required this.round,
    required this.number,
    this.score,
    this.opponentScore,
    required this.isWinner,
    required this.status,
    required this.scheduledStart,
    required this.actualStart,
    required this.mat,
    this.penalties,
    this.opponentPenalties,
    required this.competitorPosition,
  });

  factory MatchProgression.fromJson(Map<String, dynamic> json) {
    return MatchProgression(
      id: json['_id'] as String?,
      event: Event.fromJson(json['event'] as Map<String, dynamic>),
      phase: json['phase'] as String,
      positionReference: json['positionReference'] as String?,
      round: json['round'] as int,
      number: json['number'] as String,
      score: json['score'] as int?,
      opponentScore: json['opponentScore'] as int?,
      isWinner: json['isWinner'] as bool,
      status: json['status'] as String,
      scheduledStart: json['scheduledStart'] as String,
      actualStart: json['actualStart'] as String,
      mat: json['mat'] as int,
      penalties: json['penalties'] as int?,
      opponentPenalties: json['opponentPenalties'] as int?,
      competitorPosition: json['competitorPosition'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'event': event.toJson(),
      'phase': phase,
      if (positionReference != null) 'positionReference': positionReference,
      'round': round,
      'number': number,
      if (score != null) 'score': score,
      if (opponentScore != null) 'opponentScore': opponentScore,
      'isWinner': isWinner,
      'status': status,
      'scheduledStart': scheduledStart,
      'actualStart': actualStart,
      'mat': mat,
      if (penalties != null) 'penalties': penalties,
      if (opponentPenalties != null) 'opponentPenalties': opponentPenalties,
      'competitorPosition': competitorPosition,
    };
  }
}

class Event {
  final String? id;
  final String discipline;
  final String division;
  final String gender;
  final String name;
  final String weightCategory;

  Event({
    this.id,
    required this.discipline,
    required this.division,
    required this.gender,
    required this.name,
    required this.weightCategory,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'] as String?,
      discipline: json['discipline'] as String,
      division: json['division'] as String,
      gender: json['gender'] as String,
      name: json['name'] as String,
      weightCategory: json['weightCategory'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'discipline': discipline,
      'division': division,
      'gender': gender,
      'name': name,
      'weightCategory': weightCategory,
    };
  }
}

class MatchHistory {
  final int round;
  final String phase;
  final String number;
  final int mat;
  final int? score;
  final bool isWinner;
  final String status;
  final String scheduledStart;
  final String actualStart;

  MatchHistory({
    required this.round,
    required this.phase,
    required this.number,
    required this.mat,
    this.score,
    required this.isWinner,
    required this.status,
    required this.scheduledStart,
    required this.actualStart,
  });

  factory MatchHistory.fromJson(Map<String, dynamic> json) {
    return MatchHistory(
      round: json['round'] as int,
      phase: json['phase'] as String,
      number: json['number'] as String,
      mat: json['mat'] as int,
      score: json['score'] as int?,
      isWinner: json['isWinner'] as bool,
      status: json['status'] as String,
      scheduledStart: json['scheduledStart'] as String,
      actualStart: json['actualStart'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'round': round,
      'phase': phase,
      'number': number,
      'mat': mat,
      if (score != null) 'score': score,
      'isWinner': isWinner,
      'status': status,
      'scheduledStart': scheduledStart,
      'actualStart': actualStart,
    };
  }
}

class Official {
  final String id;
  final OfficialAttributes attributes;
  final String function;

  Official({
    required this.id,
    required this.attributes,
    required this.function,
  });

  factory Official.fromJson(Map<String, dynamic> json) {
    return Official(
      id: json['id'] as String,
      attributes: OfficialAttributes.fromJson(
        json['attributes'] as Map<String, dynamic>,
      ),
      function: json['function'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'attributes': attributes.toJson(), 'function': function};
  }
}

class OfficialAttributes {
  final String licenseNumber;
  final String givenName;
  final String familyName;
  final String printName;
  final String gender;
  final String country;
  final String mainRole;

  OfficialAttributes({
    required this.licenseNumber,
    required this.givenName,
    required this.familyName,
    required this.printName,
    required this.gender,
    required this.country,
    required this.mainRole,
  });

  factory OfficialAttributes.fromJson(Map<String, dynamic> json) {
    return OfficialAttributes(
      licenseNumber: json['licenseNumber'] as String,
      givenName: json['givenName'] as String,
      familyName: json['familyName'] as String,
      printName: json['printName'] as String,
      gender: json['gender'] as String,
      country: json['country'] as String,
      mainRole: json['mainRole'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'licenseNumber': licenseNumber,
      'givenName': givenName,
      'familyName': familyName,
      'printName': printName,
      'gender': gender,
      'country': country,
      'mainRole': mainRole,
    };
  }
}

class TeamDetails {
  final List<Athlete> athletes;
  final List<Official> officials;

  TeamDetails({required this.athletes, required this.officials});

  factory TeamDetails.fromJson(Map<String, dynamic> json) {
    return TeamDetails(
      athletes:
          (json['athletes'] as List<dynamic>?)
              ?.map((e) => Athlete.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      officials:
          (json['officials'] as List<dynamic>?)
              ?.map((e) => Official.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'athletes': athletes.map((e) => e.toJson()).toList(),
      'officials': officials.map((e) => e.toJson()).toList(),
    };
  }
}

class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalItems: json['totalItems'] ?? 0,
      itemsPerPage: json['itemsPerPage'] ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalItems': totalItems,
      'itemsPerPage': itemsPerPage,
    };
  }
}
