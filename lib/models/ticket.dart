class Ticket {
  final String? id;
  final String ticketId;
  final String name;
  final String date;
  final String? venue;
  final List<TicketDay> days;
  final String firstName;
  final String lastName;
  final String email;
  final String contactNumber;
  final int numberOfTickets;
  final String ticketType;
  final TicketDay selectedDay;
  final double ticketPrice;
  final double totalAmount;
  final String status;
  final String? bookingReference;
  final String paymentStatus;
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Ticket({
    this.id,
    required this.ticketId,
    required this.name,
    required this.date,
    this.venue,
    required this.days,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.contactNumber,
    required this.numberOfTickets,
    required this.ticketType,
    required this.selectedDay,
    required this.ticketPrice,
    required this.totalAmount,
    this.status = 'pending',
    this.bookingReference,
    this.paymentStatus = 'pending',
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['_id'] as String?,
      ticketId: json['id'] as String,
      name: json['name'] as String,
      date: json['date'] as String,
      venue: json['venue'] as String?,
      days: (json['days'] as List<dynamic>)
          .map((e) => TicketDay.fromJson(e as Map<String, dynamic>))
          .toList(),
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      contactNumber: json['contactNumber'] as String,
      numberOfTickets: json['numberOfTickets'] as int,
      ticketType: json['ticketType'] as String,
      selectedDay: TicketDay.fromJson(
        json['selectedDay'] as Map<String, dynamic>,
      ),
      ticketPrice: (json['ticketPrice'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'] as String? ?? 'pending',
      bookingReference: json['bookingReference'] as String?,
      paymentStatus: json['paymentStatus'] as String? ?? 'pending',
      createdBy: json['createdBy'] as String,
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
      'id': ticketId,
      'name': name,
      'date': date,
      if (venue != null) 'venue': venue,
      'days': days.map((e) => e.toJson()).toList(),
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'contactNumber': contactNumber,
      'numberOfTickets': numberOfTickets,
      'ticketType': ticketType,
      'selectedDay': selectedDay.toJson(),
      'ticketPrice': ticketPrice,
      'totalAmount': totalAmount,
      'status': status,
      if (bookingReference != null) 'bookingReference': bookingReference,
      'paymentStatus': paymentStatus,
      'createdBy': createdBy,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}

class TicketDay {
  final String id;
  final String label;
  final String date;
  final String weekday;

  TicketDay({
    required this.id,
    required this.label,
    required this.date,
    required this.weekday,
  });

  factory TicketDay.fromJson(Map<String, dynamic> json) {
    return TicketDay(
      id: json['id'] as String,
      label: json['label'] as String,
      date: json['date'] as String,
      weekday: json['weekday'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'label': label, 'date': date, 'weekday': weekday};
  }
}
