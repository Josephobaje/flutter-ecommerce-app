import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../state/cart_model.dart';
import '../utils/currency.dart';
import '../widgets/cart_button.dart';
import '../widgets/product_image.dart';
import '../widgets/quantity_stepper.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(p.category), actions: const [CartButton(), SizedBox(width: 8)]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(aspectRatio: 1.3, child: ProductImage(product: p, size: 120, radius: 28)),
          const SizedBox(height: 20),
          Text(p.name, style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber),
              Text(' ${p.rating}  ·  ${p.reviews} reviews', style: text.bodyMedium),
              const Spacer(),
              Text(p.stock <= 5 ? 'Only ${p.stock} left!' : 'In stock', style: TextStyle(color: p.stock <= 5 ? Colors.red : Colors.green, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatNaira(p.price), style: text.headlineMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w900)),
              if (p.oldPrice != null) ...[
                const SizedBox(width: 10),
                Text(formatNaira(p.oldPrice!), style: text.titleMedium?.copyWith(decoration: TextDecoration.lineThrough, color: scheme.outline)),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text('Description', style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(p.description, style: text.bodyLarge?.copyWith(height: 1.5)),
          const SizedBox(height: 16),
          const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.local_shipping_outlined), title: Text('Delivery in 1-3 days'), subtitle: Text('Lagos, Abuja, Port Harcourt and 30+ cities')),
          const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.verified_user_outlined), title: Text('7-day free returns'), subtitle: Text('Secure payments with Paystack & Flutterwave')),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              QuantityStepper(value: _qty, max: p.stock, onChanged: (v) => setState(() => _qty = v.clamp(1, p.stock))),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    context.read<CartModel>().add(p, quantity: _qty);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added $_qty × ${p.name}')));
                  },
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text('Add to cart · ${formatNaira(p.price * _qty)}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
