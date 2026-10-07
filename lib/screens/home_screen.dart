import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/catalog.dart';
import '../state/catalog_model.dart';
import '../widgets/cart_button.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catalogModel = context.watch<CatalogModel>();
    final products = catalogModel.visible;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Deliver to', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.outline)),
            const Row(children: [Icon(Icons.location_on, size: 16), SizedBox(width: 2), Text('Lekki, Lagos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))]),
          ],
        ),
        actions: const [CartButton(), SizedBox(width: 8)],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: TextField(
                key: const Key('search'),
                onChanged: context.read<CatalogModel>().search,
                decoration: const InputDecoration(hintText: 'Search phones, fashion, home...', prefixIcon: Icon(Icons.search)),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(colors: [scheme.primary, scheme.tertiary]),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mega October Sale', style: TextStyle(color: scheme.onPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text('Use code JO10 for 10% off.\nFree delivery over ₦100,000.', style: TextStyle(color: scheme.onPrimary.withValues(alpha: 0.9))),
                      ],
                    ),
                  ),
                  Icon(Icons.local_offer, color: scheme.onPrimary, size: 48),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 60,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) => ChoiceChip(
                  label: Text(categories[i]),
                  selected: catalogModel.category == categories[i],
                  onSelected: (_) => context.read<CatalogModel>().selectCategory(categories[i]),
                ),
              ),
            ),
          ),
          if (products.isEmpty)
            const SliverFillRemaining(hasScrollBody: false, child: Center(child: Text('No products match your search')))
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 220, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.68),
                itemCount: products.length,
                itemBuilder: (_, i) => ProductCard(product: products[i]),
              ),
            ),
        ],
      ),
    );
  }
}
