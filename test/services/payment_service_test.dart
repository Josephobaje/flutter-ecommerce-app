import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shop_ease/services/payment_service.dart';

void main() {
  const request = PaymentRequest(email: 'ada@example.com', amount: 45000, reference: 'SE-1');

  test('converts naira to kobo for gateways', () {
    expect(request.amountInKobo, 4500000);
  });

  test('routes to the chosen gateway', () async {
    final service = PaymentService(gateways: {
      for (final m in PaymentMethod.values) m: SimulatedGateway(m, delay: Duration.zero, shouldSucceed: m != PaymentMethod.flutterwave),
    });
    expect((await service.pay(PaymentMethod.paystack, request)).isSuccess, isTrue);
    final failed = await service.pay(PaymentMethod.flutterwave, request);
    expect(failed.status, PaymentStatus.failed);
    expect(failed.reference, 'SE-1');
  });

  test('rejects non-positive amounts without calling the gateway', () async {
    final result = await PaymentService().pay(PaymentMethod.paystack, const PaymentRequest(email: 'a@b.co', amount: 0, reference: 'R'));
    expect(result.status, PaymentStatus.failed);
  });

  test('generates unique references', () {
    final a = generateReference(Random(1));
    final b = generateReference(Random(2));
    expect(a, matches(RegExp(r'^SE-\d+-[0-9A-Z]{10}$')));
    expect(a, isNot(b));
  });
}
