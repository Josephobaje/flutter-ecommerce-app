import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/cart_model.dart';
import '../utils/currency.dart';
import '../widgets/order_summary.dart';
import '../widgets/product_image.dart';
import '../widgets/quantity_stepper.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _coupon = TextEditingController();
  String? _couponError;

  @override
  void dispose() {
    _coupon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();

    return Scaffold(
      appBar: AppBar(title: Text('My cart (${cart.count})')),
      body: cart.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(Icons.shopping_bag_outlined, size: 72), SizedBox(height: 12), Text('Your cart is empty')],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final item in cart.items)
                  Dismissible(
                    key: ValueKey(item.product.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => context.read<CartModel>().remove(item.product.id),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red.shade400,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            SizedBox(width: 72, height: 72, child: ProductImage(product: item.product, size: 34, radius: 14)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(formatNaira(item.lineTotal), style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ),
                            QuantityStepper(
                              value: item.quantity,
                              max: item.product.stock,
                              onChanged: (q) => context.read<CartModel>().setQuantity(item.product.id, q),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                if (cart.coupon == null)
                  TextField(
                    controller: _coupon,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Coupon code (try JO10)',
                      prefixIcon: const Icon(Icons.confirmation_number_outlined),
                      errorText: _couponError,
                      suffixIcon: TextButton(
                        onPressed: () {
                          final ok = context.read<CartModel>().applyCoupon(_coupon.text);
                          setState(() => _couponError = ok ? null : 'Invalid coupon code');
                        },
                        child: const Text('Apply'),
                      ),
                    ),
                  )
                else
                  Chip(
                    avatar: const Icon(Icons.check_circle, color: Colors.green),
                    label: Text('Coupon ${cart.coupon} applied'),
                    onDeleted: context.read<CartModel>().removeCoupon,
                  ),
                const SizedBox(height: 12),
                const OrderSummary(),
              ],
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: FilledButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen())),
                  child: Text('Checkout · ${formatNaira(cart.total)}'),
                ),
              ),
            ),
    );
  }
}
