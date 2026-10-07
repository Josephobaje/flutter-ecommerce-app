import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

/// Shopping cart state. Amounts are whole naira.
class CartModel extends ChangeNotifier {
  static const freeDeliveryThreshold = 100000;
  static const deliveryFee = 2500;
  static const coupons = {'JO10': 10, 'WELCOME5': 5};

  final Map<String, CartItem> _items = {};
  String? _coupon;

  List<CartItem> get items => List.unmodifiable(_items.values);
  bool get isEmpty => _items.isEmpty;
  int get count => _items.values.fold(0, (sum, i) => sum + i.quantity);
  String? get coupon => _coupon;

  int quantityOf(String productId) => _items[productId]?.quantity ?? 0;

  int get subtotal => _items.values.fold(0, (sum, i) => sum + i.lineTotal);
  int get discount => _coupon == null ? 0 : (subtotal * coupons[_coupon]! / 100).round();
  int get delivery => isEmpty || subtotal - discount >= freeDeliveryThreshold ? 0 : deliveryFee;
  int get total => subtotal - discount + delivery;

  void add(Product product, {int quantity = 1}) {
    final item = _items[product.id];
    final current = item?.quantity ?? 0;
    final next = (current + quantity).clamp(0, product.stock);
    if (next == 0) return;
    if (item == null) {
      _items[product.id] = CartItem(product: product, quantity: next);
    } else {
      item.quantity = next;
    }
    notifyListeners();
  }

  void setQuantity(String productId, int quantity) {
    final item = _items[productId];
    if (item == null) return;
    if (quantity <= 0) {
      _items.remove(productId);
    } else {
      item.quantity = quantity.clamp(1, item.product.stock);
    }
    notifyListeners();
  }

  void remove(String productId) {
    if (_items.remove(productId) != null) notifyListeners();
  }

  /// Returns true if the coupon was applied.
  bool applyCoupon(String code) {
    final normalized = code.trim().toUpperCase();
    if (!coupons.containsKey(normalized)) return false;
    _coupon = normalized;
    notifyListeners();
    return true;
  }

  void removeCoupon() {
    _coupon = null;
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _coupon = null;
    notifyListeners();
  }
}
