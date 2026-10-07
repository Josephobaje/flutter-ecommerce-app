import 'package:flutter/material.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.rating,
    required this.reviews,
    required this.icon,
    required this.color,
    this.oldPrice,
    this.stock = 20,
  });

  final String id;
  final String name;
  final String category;

  /// Price in whole naira.
  final int price;
  final int? oldPrice;
  final String description;
  final double rating;
  final int reviews;
  final IconData icon;
  final Color color;
  final int stock;

  int? get discountPercent =>
      oldPrice == null || oldPrice! <= price ? null : (((oldPrice! - price) / oldPrice!) * 100).round();
}
