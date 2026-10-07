import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/cart_model.dart';
import '../utils/currency.dart';

class OrderSummary extends StatelessWidget {
  const OrderSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();
    Widget row(String label, String value, {bool bold = false, Color? color}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Text(label, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.normal, fontSize: bold ? 17 : 14)),
              const Spacer(),
              Text(value, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600, fontSize: bold ? 17 : 14, color: color)),
            ],
          ),
        );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            row('Subtotal (${cart.count} items)', formatNaira(cart.subtotal)),
            if (cart.discount > 0) row('Discount (${cart.coupon})', '-${formatNaira(cart.discount)}', color: Colors.green),
            row('Delivery', cart.delivery == 0 ? 'FREE' : formatNaira(cart.delivery)),
            const Divider(height: 20),
            row('Total', formatNaira(cart.total), bold: true),
          ],
        ),
      ),
    );
  }
}
