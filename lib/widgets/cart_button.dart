import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/cart_screen.dart';
import '../state/cart_model.dart';

class CartButton extends StatelessWidget {
  const CartButton({super.key});

  @override
  Widget build(BuildContext context) {
    final count = context.select<CartModel, int>((c) => c.count);
    return IconButton(
      tooltip: 'Cart',
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count', key: const Key('cart-count')),
        child: const Icon(Icons.shopping_bag_outlined),
      ),
    );
  }
}
