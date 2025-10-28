class PaymentIntent {
  final String clientSecret;
  final String paymentIntentId;
  final int amount;
  final List<String> ticketIds;
  final List<String> paymentIds;

  PaymentIntent({
    required this.clientSecret,
    required this.paymentIntentId,
    required this.amount,
    required this.ticketIds,
    required this.paymentIds,
  });

  factory PaymentIntent.fromJson(Map<String, dynamic> json) {
    return PaymentIntent(
      clientSecret: json['clientSecret'] as String,
      paymentIntentId: json['paymentIntentId'] as String,
      amount: json['amount'] as int,
      ticketIds: List<String>.from(json['ticketIds'] as List),
      paymentIds: List<String>.from(json['paymentIds'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientSecret': clientSecret,
      'paymentIntentId': paymentIntentId,
      'amount': amount,
      'ticketIds': ticketIds,
      'paymentIds': paymentIds,
    };
  }
}
