import 'package:flutter_test/flutter_test.dart';
import 'package:shop_ease/data/catalog.dart';
import 'package:shop_ease/state/cart_model.dart';
import 'package:shop_ease/state/catalog_model.dart';

void main() {
  final phone = catalog.firstWhere((p) => p.id == 'p1'); // ₦389,000, stock 12
  final butter = catalog.firstWhere((p) => p.id == 'p7'); // ₦9,500

  group('CartModel', () {
    test('adds items and merges quantities', () {
      final cart = CartModel()
        ..add(butter)
        ..add(butter, quantity: 2);
      expect(cart.items, hasLength(1));
      expect(cart.count, 3);
      expect(cart.subtotal, 28500);
    });

    test('never exceeds stock', () {
      final cart = CartModel()..add(phone, quantity: 50);
      expect(cart.quantityOf('p1'), 12);
      cart.setQuantity('p1', 99);
      expect(cart.quantityOf('p1'), 12);
    });

    test('setting quantity to zero removes the item', () {
      final cart = CartModel()..add(butter);
      cart.setQuantity('p7', 0);
      expect(cart.isEmpty, isTrue);
    });

    test('charges delivery below the free threshold only', () {
      final small = CartModel()..add(butter);
      expect(small.delivery, CartModel.deliveryFee);
      expect(small.total, 9500 + CartModel.deliveryFee);
      final big = CartModel()..add(phone);
      expect(big.delivery, 0);
      expect(CartModel().delivery, 0);
    });

    test('applies valid coupons case-insensitively and rejects others', () {
      final cart = CartModel()..add(phone);
      expect(cart.applyCoupon('fake'), isFalse);
      expect(cart.applyCoupon(' jo10 '), isTrue);
      expect(cart.discount, 38900);
      expect(cart.total, 389000 - 38900);
      cart.removeCoupon();
      expect(cart.discount, 0);
    });

    test('notifies listeners on change and clear resets everything', () {
      var calls = 0;
      final cart = CartModel()..addListener(() => calls++);
      cart
        ..add(butter)
        ..applyCoupon('WELCOME5')
        ..clear();
      expect(calls, 3);
      expect(cart.isEmpty, isTrue);
      expect(cart.coupon, isNull);
    });
  });

  group('CatalogModel', () {
    test('filters by category and search query', () {
      final model = CatalogModel();
      expect(model.visible, hasLength(catalog.length));
      model.selectCategory('Fashion');
      expect(model.visible.every((p) => p.category == 'Fashion'), isTrue);
      model
        ..selectCategory('All')
        ..search('fan');
      expect(model.visible.single.name, 'Standing Fan 18"');
    });

    test('toggles favourites', () {
      final model = CatalogModel()..toggleFavorite('p3');
      expect(model.isFavorite('p3'), isTrue);
      model.toggleFavorite('p3');
      expect(model.isFavorite('p3'), isFalse);
    });
  });
}
