import 'dart:math';

/// Payment methods offered at checkout.
enum PaymentMethod {
  paystack('Paystack', 'Card, bank transfer, USSD'),
  flutterwave('Flutterwave', 'Card, mobile money, bank'),
  payOnDelivery('Pay on delivery', 'Cash or POS when your order arrives');

  const PaymentMethod(this.label, this.subtitle);
  final String label;
  final String subtitle;
}

class PaymentRequest {
  const PaymentRequest({required this.email, required this.amount, required this.reference, this.metadata = const {}});

  final String email;

  /// Whole naira. Gateways expect kobo, see [amountInKobo].
  final int amount;
  final String reference;
  final Map<String, Object?> metadata;

  int get amountInKobo => amount * 100;
}

enum PaymentStatus { success, cancelled, failed }

class PaymentResult {
  const PaymentResult(this.status, this.reference, {this.message});
  final PaymentStatus status;
  final String reference;
  final String? message;
  bool get isSuccess => status == PaymentStatus.success;
}

/// The app talks to this interface only, so a real gateway SDK can be swapped in
/// without touching the UI.
abstract class PaymentGateway {
  PaymentMethod get method;
  Future<PaymentResult> charge(PaymentRequest request);
}

String generateReference([Random? random]) {
  final r = random ?? Random.secure();
  final suffix = List.generate(10, (_) => r.nextInt(36).toRadixString(36)).join().toUpperCase();
  return 'SE-${DateTime.now().millisecondsSinceEpoch}-$suffix';
}

/// Demo gateway that simulates a successful payment.
///
/// To go live with Paystack, implement [PaymentGateway] with a Paystack SDK
/// (for example `flutter_paystack_plus`) or open the `authorization_url` returned by
/// your backend's `/transaction/initialize` call in a WebView, then **verify the
/// reference on your server** before fulfilling the order. Never ship your secret key
/// in the app; only the public key belongs on the device.
class SimulatedGateway implements PaymentGateway {
  SimulatedGateway(this.method, {this.delay = const Duration(milliseconds: 1200), this.shouldSucceed = true});

  @override
  final PaymentMethod method;
  final Duration delay;
  final bool shouldSucceed;

  @override
  Future<PaymentResult> charge(PaymentRequest request) async {
    await Future<void>.delayed(delay);
    return shouldSucceed
        ? PaymentResult(PaymentStatus.success, request.reference, message: '${method.label} payment approved')
        : PaymentResult(PaymentStatus.failed, request.reference, message: 'Payment declined');
  }
}

class PaymentService {
  PaymentService({Map<PaymentMethod, PaymentGateway>? gateways})
      : _gateways = gateways ?? {for (final m in PaymentMethod.values) m: SimulatedGateway(m)};

  final Map<PaymentMethod, PaymentGateway> _gateways;

  Future<PaymentResult> pay(PaymentMethod method, PaymentRequest request) {
    if (request.amount <= 0) {
      return Future.value(PaymentResult(PaymentStatus.failed, request.reference, message: 'Invalid amount'));
    }
    return _gateways[method]!.charge(request);
  }
}
