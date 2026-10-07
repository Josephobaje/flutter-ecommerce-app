import 'package:flutter/material.dart';

import '../models/product.dart';

/// Gradient "product photo" built from an icon, so the demo needs no network images.
class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.product, this.size = 64, this.radius = 18});

  final Product product;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'product-${product.id}',
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [product.color.withValues(alpha: 0.85), product.color.withValues(alpha: 0.45)],
          ),
        ),
        alignment: Alignment.center,
        child: Icon(product.icon, size: size, color: Colors.white),
      ),
    );
  }
}
