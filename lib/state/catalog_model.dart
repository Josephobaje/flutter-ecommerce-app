import 'package:flutter/foundation.dart';

import '../data/catalog.dart';
import '../models/product.dart';

class CatalogModel extends ChangeNotifier {
  CatalogModel({List<Product>? products}) : _products = products ?? catalog;

  final List<Product> _products;
  String _category = 'All';
  String _query = '';
  final Set<String> _favorites = {};

  String get category => _category;
  String get query => _query;

  List<Product> get visible => _products.where((p) {
        final matchesCategory = _category == 'All' || p.category == _category;
        final q = _query.toLowerCase();
        final matchesQuery = q.isEmpty || p.name.toLowerCase().contains(q) || p.category.toLowerCase().contains(q);
        return matchesCategory && matchesQuery;
      }).toList();

  bool isFavorite(String id) => _favorites.contains(id);

  void selectCategory(String category) {
    _category = category;
    notifyListeners();
  }

  void search(String query) {
    _query = query.trim();
    notifyListeners();
  }

  void toggleFavorite(String id) {
    _favorites.contains(id) ? _favorites.remove(id) : _favorites.add(id);
    notifyListeners();
  }
}
