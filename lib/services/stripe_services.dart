import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class StripeService extends GetxService {
  final Logger _logger = Logger();

  /// Confirms payment with Stripe using CardField controller
  Future<PaymentIntent> confirmPayment(
    String clientSecret, {
    required CardEditController cardController,
  }) async {
    try {
      _logger.i('Starting payment confirmation');

      // CardField automatically handles payment method collection
      // We just need to confirm with empty params - Stripe SDK will use the card field data
      final paymentMethodParams = PaymentMethodParams.card(
        paymentMethodData: PaymentMethodData(),
      );

      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: paymentMethodParams,
      );

      _logger.i('Payment confirmed. Status: ${paymentIntent.status}');
      return paymentIntent;
    } on StripeException catch (e) {
      _logger.e('Stripe exception: ${e.error.code} - ${e.error.message}');
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error during payment: $e');
      rethrow;
    }
  }
}
