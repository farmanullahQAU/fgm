class PaymentConfirmation {
  final List<ConfirmedTicket> tickets;
  final List<Payment> payments;
  final double totalAmount;
  final List<String> ticketIds;

  PaymentConfirmation({
    required this.tickets,
    required this.payments,
    required this.totalAmount,
    required this.ticketIds,
  });

  factory PaymentConfirmation.fromJson(Map<String, dynamic> json) {
    return PaymentConfirmation(
      tickets:
          (json['tickets'] as List<dynamic>?)
              ?.map((e) => ConfirmedTicket.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      payments:
          (json['payments'] as List<dynamic>?)
              ?.map((e) => Payment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      ticketIds:
          (json['ticketIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tickets': tickets.map((e) => e.toJson()).toList(),
      'payments': payments.map((e) => e.toJson()).toList(),
      'totalAmount': totalAmount,
      'ticketIds': ticketIds,
    };
  }
}

class ConfirmedTicket {
  final String? id;
  final String ticketNumber;
  final Map<String, dynamic> event;
  final int numberOfTickets;
  final double totalAmount;

  ConfirmedTicket({
    this.id,
    required this.ticketNumber,
    required this.event,
    required this.numberOfTickets,
    required this.totalAmount,
  });

  factory ConfirmedTicket.fromJson(Map<String, dynamic> json) {
    return ConfirmedTicket(
      id: json['_id'] as String?,
      ticketNumber: json['ticketNumber'] ?? "",
      event: json['event'] as Map<String, dynamic>? ?? {},
      numberOfTickets: json['numberOfTickets'] ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'ticketNumber': ticketNumber,
      'event': event,
      'numberOfTickets': numberOfTickets,
      'totalAmount': totalAmount,
    };
  }
}

class Payment {
  final Map<String, dynamic> data;

  Payment({required this.data});

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(data: json);
  }

  Map<String, dynamic> toJson() {
    return data;
  }
}
