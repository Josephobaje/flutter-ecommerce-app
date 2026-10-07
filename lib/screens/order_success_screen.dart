import 'package:flutter/material.dart';

import '../services/payment_service.dart';
import '../utils/currency.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.reference, required this.total, required this.method});

  final String reference;
  final int total;
  final PaymentMethod method;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(radius: 48, backgroundColor: Colors.green.shade100, child: Icon(Icons.check_rounded, size: 56, color: Colors.green.shade700)),
              const SizedBox(height: 20),
              Text('Order placed!', style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('${formatNaira(total)} · ${method.label}', style: text.titleMedium),
              const SizedBox(height: 4),
              SelectableText('Ref: $reference', style: text.bodySmall),
              const SizedBox(height: 12),
              const Text('We will send updates by SMS and email. Expected delivery: 1-3 working days.', textAlign: TextAlign.center),
              const SizedBox(height: 28),
              FilledButton(onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst), child: const Text('Continue shopping')),
            ],
          ),
        ),
      ),
    );
  }
}
