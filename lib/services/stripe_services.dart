import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class StripeService extends GetxService {
  final Logger _logger = Logger();

  Future<PaymentIntent> confirmPaymentWithCardForm(String clientSecret) async {
    try {
      // This will:
      // 1. Get card details from CardFormField (user filled)
      // 2. Create a PaymentMethod
      // 3. Confirm the PaymentIntent with that PaymentMethod
      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      _logger.i('Payment intent status: ${paymentIntent.status}');
      return paymentIntent;
    } catch (e) {
      _logger.e('Stripe error: $e');
      rethrow;
    }
  }
}
