import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../screens/product_detail_screen.dart';
import '../state/cart_model.dart';
import '../state/catalog_model.dart';
import '../utils/currency.dart';
import 'product_image.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fav = context.select<CatalogModel, bool>((c) => c.isFavorite(product.id));
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(child: ProductImage(product: product, size: 54)),
                    if (product.discountPercent != null)
                      Positioned(
                        left: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: Colors.red.shade600, borderRadius: BorderRadius.circular(8)),
                          child: Text('-${product.discountPercent}%', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        tooltip: fav ? 'Remove from wishlist' : 'Add to wishlist',
                        onPressed: () => context.read<CatalogModel>().toggleFavorite(product.id),
                        icon: Icon(fav ? Icons.favorite : Icons.favorite_border, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                  Text(' ${product.rating}', style: Theme.of(context).textTheme.bodySmall),
                  Text(' (${product.reviews})', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.outline)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(child: Text(formatNaira(product.price), style: TextStyle(fontWeight: FontWeight.w800, color: scheme.primary, fontSize: 15))),
                  IconButton.filledTonal(
                    tooltip: 'Add ${product.name} to cart',
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      context.read<CartModel>().add(product);
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(content: Text('${product.name} added to cart'), duration: const Duration(seconds: 1)));
                    },
                    icon: const Icon(Icons.add, size: 18),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
