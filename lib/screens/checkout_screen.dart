import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/payment_service.dart';
import '../state/cart_model.dart';
import '../utils/currency.dart';
import '../utils/validators.dart';
import '../widgets/order_summary.dart';
import 'order_success_screen.dart';

const nigerianStates = ['Lagos', 'FCT Abuja', 'Rivers', 'Kano', 'Oyo', 'Enugu', 'Kaduna', 'Kogi', 'Benue', 'Delta'];

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  String _state = 'Lagos';
  PaymentMethod _method = PaymentMethod.paystack;
  bool _paying = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _address]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    final cart = context.read<CartModel>();
    final payments = context.read<PaymentService>();
    setState(() => _paying = true);
    final request = PaymentRequest(
      email: _email.text.trim(),
      amount: cart.total,
      reference: generateReference(),
      metadata: {'name': _name.text.trim(), 'phone': _phone.text.trim(), 'state': _state, 'items': cart.count},
    );
    final result = await payments.pay(_method, request);
    if (!mounted) return;
    setState(() => _paying = false);
    if (result.isSuccess) {
      final total = cart.total;
      cart.clear();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => OrderSuccessScreen(reference: result.reference, total: total, method: _method)),
        (route) => route.isFirst,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message ?? 'Payment failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = context.select<CartModel, int>((c) => c.total);
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Delivery details', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            TextFormField(key: const Key('name'), controller: _name, decoration: const InputDecoration(labelText: 'Full name'), validator: (v) => validateRequired(v, 'Full name')),
            const SizedBox(height: 10),
            TextFormField(key: const Key('email'), controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email'), validator: validateEmail),
            const SizedBox(height: 10),
            TextFormField(key: const Key('phone'), controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone (e.g. 0803 123 4567)'), validator: validateNigerianPhone),
            const SizedBox(height: 10),
            TextFormField(key: const Key('address'), controller: _address, decoration: const InputDecoration(labelText: 'Street address'), validator: (v) => validateRequired(v, 'Address')),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _state,
              decoration: const InputDecoration(labelText: 'State'),
              items: [for (final s in nigerianStates) DropdownMenuItem(value: s, child: Text(s))],
              onChanged: (v) => setState(() => _state = v!),
            ),
            const SizedBox(height: 20),
            Text('Payment method', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            RadioGroup<PaymentMethod>(
              groupValue: _method,
              onChanged: (m) => setState(() => _method = m!),
              child: Column(
                children: [
                  for (final m in PaymentMethod.values)
                    Card(
                      child: RadioListTile<PaymentMethod>(
                        value: m,
                        title: Text(m.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(m.subtitle),
                        secondary: Icon(switch (m) {
                          PaymentMethod.paystack => Icons.credit_card,
                          PaymentMethod.flutterwave => Icons.account_balance_wallet_outlined,
                          PaymentMethod.payOnDelivery => Icons.payments_outlined,
                        }),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const OrderSummary(),
            const SizedBox(height: 8),
            Text('Demo mode: payments are simulated. See README to connect live Paystack or Flutterwave keys via your backend.',
                style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(
            key: const Key('pay'),
            onPressed: _paying ? null : _placeOrder,
            child: _paying
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                : Text(_method == PaymentMethod.payOnDelivery ? 'Place order · ${formatNaira(total)}' : 'Pay ${formatNaira(total)} with ${_method.label}'),
          ),
        ),
      ),
    );
  }
}
