class PurchasedTicket {
  final String id;
  final PurchasedEvent event;
  final String firstName;
  final String lastName;
  final String email;
  final String contactNumber;
  final int numberOfTickets;
  final String ticketType;
  final List<String> selectedDates;
  final double ticketPrice;
  final double totalAmount;
  final String status;
  final String bookingReference;
  final String paymentStatus;
  final Payment? payment;
  final int numberOfDays;

  PurchasedTicket({
    required this.id,
    required this.event,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.contactNumber,
    required this.numberOfTickets,
    required this.ticketType,
    required this.selectedDates,
    required this.ticketPrice,
    required this.totalAmount,
    required this.status,
    required this.bookingReference,
    required this.paymentStatus,
    this.payment,
    required this.numberOfDays,
  });

  factory PurchasedTicket.fromJson(Map<String, dynamic> json) {
    return PurchasedTicket(
      id: json['_id'] as String,
      event: PurchasedEvent.fromJson(json['event'] as Map<String, dynamic>),
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      contactNumber: json['contactNumber'] as String,
      numberOfTickets: json['numberOfTickets'] as int,
      ticketType: json['ticketType'] as String,
      selectedDates: (json['selectedDates'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      ticketPrice: (json['ticketPrice'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'] as String,
      bookingReference: json['bookingReference'] as String,
      paymentStatus: json['paymentStatus'] as String,
      payment: json['payment'] != null
          ? Payment.fromJson(json['payment'] as Map<String, dynamic>)
          : null,
      numberOfDays: json['numberOfDays'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'event': event.toJson(),
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'contactNumber': contactNumber,
      'numberOfTickets': numberOfTickets,
      'ticketType': ticketType,
      'selectedDates': selectedDates,
      'ticketPrice': ticketPrice,
      'totalAmount': totalAmount,
      'status': status,
      'bookingReference': bookingReference,
      'paymentStatus': paymentStatus,
      'payment': payment?.toJson(),
      'numberOfDays': numberOfDays,
    };
  }
}

class PurchasedEvent {
  final String id;
  final String name;
  final String location;
  final String image;
  final String startDate;
  final String endDate;

  PurchasedEvent({
    required this.id,
    required this.name,
    required this.location,
    required this.image,
    required this.startDate,
    required this.endDate,
  });

  factory PurchasedEvent.fromJson(Map<String, dynamic> json) {
    return PurchasedEvent(
      id: json['_id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      image: json['image'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'location': location,
      'image': image,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}

class Payment {
  final String id;
  final double amount;
  final String paymentStatus;
  final String paidAt;

  Payment({
    required this.id,
    required this.amount,
    required this.paymentStatus,
    required this.paidAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentStatus: json['paymentStatus'] as String,
      paidAt: json['paidAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'amount': amount,
      'paymentStatus': paymentStatus,
      'paidAt': paidAt,
    };
  }
}

