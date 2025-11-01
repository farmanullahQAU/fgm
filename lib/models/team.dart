class Team {
  final String? id;
  final String teamId;
  final TeamAttributes? attributes;
  final int athleteCount;
  final int officialCount;
  final Country? country;
  final int totalParticipants;

  Team({
    this.id,
    required this.teamId,
    this.attributes,
    required this.athleteCount,
    required this.officialCount,
    this.country,
    required this.totalParticipants,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['_id'] as String?,
      teamId: json['id'] as String,
      attributes: json['attributes'] != null
          ? TeamAttributes.fromJson(json['attributes'] as Map<String, dynamic>)
          : null,
      athleteCount: json['athleteCount'] as int? ?? 0,
      officialCount: json['officialCount'] as int? ?? 0,
      country:
          json['country'] != null &&
              (json['country'] as Map<String, dynamic>).isNotEmpty
          ? Country.fromJson(json['country'] as Map<String, dynamic>)
          : null,
      totalParticipants: json['totalParticipants'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'id': teamId,
      if (attributes != null) 'attributes': attributes!.toJson(),
      'athleteCount': athleteCount,
      'officialCount': officialCount,
      if (country != null) 'country': country!.toJson(),
      'totalParticipants': totalParticipants,
    };
  }

  // Helper methods to get country info
  String getCountryCode() {
    if (country?.code != null && country!.code!.isNotEmpty) {
      return country!.code!;
    }
    if (attributes?.country != null && attributes!.country.isNotEmpty) {
      return attributes!.country;
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

  String getTeamName() {
    if (attributes?.name != null && attributes!.name.isNotEmpty) {
      return attributes!.name;
    }
    return '';
  }
}

class TeamAttributes {
  final String name;
  final String country;

  TeamAttributes({required this.name, required this.country});

  factory TeamAttributes.fromJson(Map<String, dynamic> json) {
    return TeamAttributes(
      name: json['name'] as String? ?? '',
      country: json['country'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'country': country};
  }
}

class Country {
  final String? code;
  final String? name;
  final String? continent;
  final String? flag;
  final String? flagEmoji;
  final String? capital;
  final String? currency;
  final String? language;
  final String? timezone;

  Country({
    this.code,
    this.name,
    this.continent,
    this.flag,
    this.flagEmoji,
    this.capital,
    this.currency,
    this.language,
    this.timezone,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      code: json['code'] as String?,
      name: json['name'] as String?,
      continent: json['continent'] as String?,
      flag: json['flag'] as String?,
      flagEmoji: json['flagEmoji'] as String?,
      capital: json['capital'] as String?,
      currency: json['currency'] as String?,
      language: json['language'] as String?,
      timezone: json['timezone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (continent != null) 'continent': continent,
      if (flag != null) 'flag': flag,
      if (flagEmoji != null) 'flagEmoji': flagEmoji,
      if (capital != null) 'capital': capital,
      if (currency != null) 'currency': currency,
      if (language != null) 'language': language,
      if (timezone != null) 'timezone': timezone,
    };
  }
}
