// lib/models/cart_item.dart

import 'package:craft/models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  // Serialization methods
  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(),
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      product: Product.fromJson(map['product']),
      quantity: map['quantity'] ?? 1,
    );
  }
}