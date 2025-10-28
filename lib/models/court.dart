class Court {
  final int liveMatches;
  final int upcomingMatches;
  final int completedMatches;
  final String courtNumber;
  final int mat;
  final int totalMatches;

  Court({
    required this.liveMatches,
    required this.upcomingMatches,
    required this.completedMatches,
    required this.courtNumber,
    required this.mat,
    required this.totalMatches,
  });

  factory Court.fromJson(Map<String, dynamic> json) {
    return Court(
      liveMatches: json['liveMatches'] as int,
      upcomingMatches: json['upcomingMatches'] as int,
      completedMatches: json['completedMatches'] as int,
      courtNumber: json['courtNumber'] as String,
      mat: json['mat'] as int,
      totalMatches: json['totalMatches'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'liveMatches': liveMatches,
      'upcomingMatches': upcomingMatches,
      'completedMatches': completedMatches,
      'courtNumber': courtNumber,
      'mat': mat,
      'totalMatches': totalMatches,
    };
  }
}

