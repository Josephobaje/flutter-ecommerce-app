import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_ease/app.dart';
import 'package:shop_ease/services/payment_service.dart';

void main() {
  PaymentService instantPayments() =>
      PaymentService(gateways: {for (final m in PaymentMethod.values) m: SimulatedGateway(m, delay: const Duration(milliseconds: 10))});

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ShopEaseApp(paymentService: instantPayments()));
  }

  testWidgets('adding a product updates the cart badge', (tester) async {
    await pumpApp(tester);
    expect(find.byKey(const Key('cart-count')), findsNothing);
    await tester.tap(find.byTooltip('Add Wireless Earbuds Pro to cart'));
    await tester.pump();
    expect(find.text('Wireless Earbuds Pro added to cart'), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const Key('cart-count'))).data, '1');
  });

  testWidgets('category chips and search filter the grid', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Fashion'));
    await tester.pumpAndSettle();
    expect(find.text('Ankara Maxi Dress'), findsOneWidget);
    expect(find.text('Gaming Controller'), findsNothing);
    await tester.tap(find.widgetWithText(ChoiceChip, 'All'));
    await tester.enterText(find.byKey(const Key('search')), 'xyz');
    await tester.pumpAndSettle();
    expect(find.text('No products match your search'), findsOneWidget);
  });

  testWidgets('full checkout flow with validation and payment', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byTooltip('Add Wireless Earbuds Pro to cart'));
    await tester.pump();
    await tester.tap(find.byTooltip('Cart'));
    await tester.pumpAndSettle();
    expect(find.text('My cart (1)'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'jo10');
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(find.text('Coupon JO10 applied'), findsOneWidget);

    await tester.tap(find.textContaining('Checkout ·'));
    await tester.pumpAndSettle();

    // Submitting an empty form shows errors.
    await tester.tap(find.byKey(const Key('pay')));
    await tester.pumpAndSettle();
    expect(find.text('Full name is required'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('name')), 'Ada Obi');
    await tester.enterText(find.byKey(const Key('email')), 'ada@example.com');
    await tester.enterText(find.byKey(const Key('phone')), '08031234567');
    await tester.enterText(find.byKey(const Key('address')), '12 Admiralty Way');
    await tester.tap(find.byKey(const Key('pay')));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(find.text('Order placed!'), findsOneWidget);
    // 38,500 - 3,850 (10%) + 2,500 delivery
    expect(find.text('₦37,150 · Paystack'), findsOneWidget);
    await tester.tap(find.text('Continue shopping'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('cart-count')), findsNothing);
  });
}
