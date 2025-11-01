import 'package:fmac/models/team.dart' show Country;

class WeightDivisionParticipant {
  final String? id;
  final String participantId;
  final ParticipantAttributes attributes;
  final List<MatchProgression> matchProgression;
  final String? organizationName;
  final List<MatchHistory> matchHistory;
  final int totalWins;
  final Country? country;
  final int rank;
  final int seed;
  final ParticipantEvent event;
  final String? profilePicture;

  WeightDivisionParticipant({
    this.id,
    required this.participantId,
    required this.attributes,
    required this.matchProgression,
    this.organizationName,
    required this.matchHistory,
    required this.totalWins,
    this.country,
    required this.rank,
    required this.seed,
    required this.event,
    this.profilePicture,
  });

  factory WeightDivisionParticipant.fromJson(Map<String, dynamic> json) {
    return WeightDivisionParticipant(
      id: json['_id'] as String?,
      participantId: json['id'] as String,
      attributes: ParticipantAttributes.fromJson(
        json['attributes'] as Map<String, dynamic>,
      ),
      matchProgression:
          (json['matchProgression'] as List<dynamic>?)
              ?.map((e) => MatchProgression.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      organizationName: json['organizationName'] as String?,
      matchHistory:
          (json['matchHistory'] as List<dynamic>?)
              ?.map((e) => MatchHistory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalWins: json['totalWins'] as int? ?? 0,
      country:
          json['country'] != null &&
              (json['country'] as Map<String, dynamic>).isNotEmpty
          ? Country.fromJson(json['country'] as Map<String, dynamic>)
          : null,
      rank: json['rank'] as int? ?? 0,
      seed: json['seed'] as int? ?? 0,
      event: ParticipantEvent.fromJson(json['event'] as Map<String, dynamic>),
      profilePicture: json['profilePicture'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'id': participantId,
      'attributes': attributes.toJson(),
      'matchProgression': matchProgression.map((e) => e.toJson()).toList(),
      if (organizationName != null) 'organizationName': organizationName,
      'matchHistory': matchHistory.map((e) => e.toJson()).toList(),
      'totalWins': totalWins,
      if (country != null) 'country': country!.toJson(),
      'rank': rank,
      'seed': seed,
      'event': event.toJson(),
      if (profilePicture != null) 'profilePicture': profilePicture,
    };
  }

  // Helper methods to get country info
  String getCountryCode() {
    if (country?.code != null && country!.code!.isNotEmpty) {
      return country!.code!;
    }
    if (attributes.country.isNotEmpty) {
      return attributes.country;
    }
    return '';
  }

  String getCountryName() {
    if (country?.name != null && country!.name!.isNotEmpty) {
      return country!.name!;
    }
    return '';
  }

  String getContinent() {
    if (country?.continent != null && country!.continent!.isNotEmpty) {
      return country!.continent!;
    }
    return '';
  }

  String getFlagEmoji() {
    if (country?.flagEmoji != null && country!.flagEmoji!.isNotEmpty) {
      return country!.flagEmoji!;
    }
    return '';
  }
}

class ParticipantAttributes {
  final String licenseNumber;
  final String givenName;
  final String familyName;
  final String printName;
  final String gender;
  final String birthDate;
  final String country;

  ParticipantAttributes({
    required this.licenseNumber,
    required this.givenName,
    required this.familyName,
    required this.printName,
    required this.gender,
    required this.birthDate,
    required this.country,
  });

  factory ParticipantAttributes.fromJson(Map<String, dynamic> json) {
    return ParticipantAttributes(
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
  final ParticipantEvent event;
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
      event: ParticipantEvent.fromJson(json['event'] as Map<String, dynamic>),
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

class ParticipantEvent {
  final String? id;
  final String? discipline;
  final String? division;
  final String? gender;
  final String? name;
  final String? weightCategory;

  ParticipantEvent({
    this.id,
    this.discipline,
    this.division,
    this.gender,
    this.name,
    this.weightCategory,
  });

  factory ParticipantEvent.fromJson(Map<String, dynamic> json) {
    return ParticipantEvent(
      id: json['_id'] as String?,
      discipline: json['discipline'] as String?,
      division: json['division'] as String?,
      gender: json['gender'] as String?,
      name: json['name'] as String?,
      weightCategory: json['weightCategory'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (discipline != null) 'discipline': discipline,
      if (division != null) 'division': division,
      if (gender != null) 'gender': gender,
      if (name != null) 'name': name,
      if (weightCategory != null) 'weightCategory': weightCategory,
    };
  }
}
