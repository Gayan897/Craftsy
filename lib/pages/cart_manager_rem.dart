import 'dart:convert';

import 'package:craft/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartManagerRem {
  // Singleton pattern
  static final CartManagerRem _instance = CartManagerRem._internal();

  factory CartManagerRem() {
    return _instance;
  }

  CartManagerRem._internal();

  // Cart items list
  List<Product> _items = [];

  // Getter for items
  List<Product> get items => _items;

  // Add to cart
  void addToCart(Product product) {
    _items.add(product);
    _saveCart();
  }

  // Remove from cart
  void removeFromCart(Product product) {
    // Find the first occurrence and remove it
    final index = _items.indexWhere((item) => item.name == product.name);

    if (index != -1) {
      _items.removeAt(index);
      _saveCart();
    }
  }

  // Remove all instances of a product from cart
  void removeAllFromCart(Product product) {
    _items.removeWhere((item) => item.name == product.name);
    _saveCart();
  }

  // Clear cart
  void clearCart() {
    _items.clear();
    _saveCart();
  }

  // Calculate total price
  double getTotal() {
    double total = 0;
    for (var item in _items) {
      total += item.price;
    }
    return total;
  }

  // Get item count for a specific product
  int getItemCount(Product product) {
    return _items.where((item) => item.name == product.name).length;
  }

  // Save cart to SharedPreferences
  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = jsonEncode(_items.map((item) => item.toMap()).toList());
    await prefs.setString('cart', cartJson);
  }

  // Load cart from SharedPreferences
  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString('cart');

      if (cartJson != null) {
        final List<dynamic> cartData = jsonDecode(cartJson);
        _items = cartData.map((data) => Product.fromJson(data)).toList();
      }
    } catch (e) {
      // Handle error, reset cart if needed
      _items = [];
    }
  }
}
