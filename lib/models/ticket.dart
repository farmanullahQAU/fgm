import '../models/user.dart'; // Assume User model is defined elsewhere

class Ticket {
  final String? id;
  final String? eventName;
  final String? date;
  final String? venue;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? contactNumber;
  final int numberOfTickets;
  final String ticketType;
  final double ticketPrice;
  final List<String> selectedDates;
  // final Event? event;
  final double totalAmount;
  final String status;
  final String bookingReference;
  final String paymentStatus;
  final User createdBy; // Changed to User type
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Ticket({
    this.id,
    this.eventName,
    required this.date,
    required this.venue,
    this.firstName,
    this.lastName,
    this.email,
    this.contactNumber,
    required this.ticketPrice,
    required this.numberOfTickets,
    required this.ticketType,
    required this.selectedDates,
    required this.totalAmount,
    // this.event,
    this.status = 'pending',
    required this.bookingReference,
    this.paymentStatus = 'pending',
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
  });
  Ticket copyWith({
    String? id,
    String? eventName,
    String? date,
    String? venue,
    String? firstName,
    String? lastName,
    String? email,
    String? contactNumber,
    int? numberOfTickets,
    String? ticketType,
    List<String>? selectedDates,
    double? ticketPrice,
    double? totalAmount,
    String? bookingReference,
    User? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
  }) {
    return Ticket(
      id: id ?? this.id,
      eventName: eventName ?? this.eventName,
      date: date ?? this.date,
      venue: venue ?? this.venue,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      contactNumber: contactNumber ?? this.contactNumber,
      numberOfTickets: numberOfTickets ?? this.numberOfTickets,
      ticketType: ticketType ?? this.ticketType,
      selectedDates: selectedDates ?? this.selectedDates,
      totalAmount: totalAmount ?? this.totalAmount,
      bookingReference: bookingReference ?? this.bookingReference,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      status: status ?? this.status,
      // event: event,
    );
  }

  factory Ticket.fromJson(dynamic json) {
    return Ticket(
      id: json['id'] ?? json['ticketId'],
      eventName: json['eventName'],
      date: json['date'],
      venue: json['venue'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      contactNumber: json['contactNumber'],
      numberOfTickets: json['numberOfTickets'] as int,
      ticketType: json['ticketType'] as String,
      selectedDates: json['datesList'] == null
          ? List<String>.from(json['selectedDates'])
          : List<String>.from(json['datesList']),
      // event: Event.fromJson(json['event']),
      ticketPrice: (json['ticketPrice'])?.toDouble() ?? 0.0,

      //calculate ticket price from total amount and number of tickets and,
      totalAmount: (json['totalAmount'])?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      bookingReference: json['bookingReference'] as String,
      paymentStatus: json['paymentStatus'] as String? ?? 'pending',
      createdBy: User.fromJson(json['createdBy']), // Parse as User
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'eventName': eventName,
      'date': date,
      'venue': venue,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      // 'event': event?.toJson(),
      'contactNumber': contactNumber,
      'numberOfTickets': numberOfTickets,
      'ticketType': ticketType,
      'selectedDates': selectedDates,
      'totalAmount': totalAmount,
      'ticketPrice': ticketPrice,
      'status': status,
      'bookingReference': bookingReference,
      'paymentStatus': paymentStatus,
      'createdBy': createdBy.toJson(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}
