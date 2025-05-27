// lib/pages/cart_manager.dart

import 'dart:convert';

import 'package:craft/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

// CartItem class definition
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

class CartManager {
  // Private constructor for singleton pattern
  CartManager._private();

  // Singleton instance
  static final CartManager _instance = CartManager._private();

  // Factory constructor to return the singleton instance
  factory CartManager() => _instance;

  // List to store cart items
  List<CartItem> _items = [];

  // Getter for cart items
  List<CartItem> get items => _items;

  // Getter for total price
  double get totalPrice {
    return _items.fold(
        0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  // Method to add product to cart
  void addToCart(Product product) {
    // Check if product already exists in cart
    final existingItemIndex = _items.indexWhere(
      (item) => item.product.name == product.name,
    );

    if (existingItemIndex >= 0) {
      // Increment quantity if product already in cart
      _items[existingItemIndex].quantity += 1;
    } else {
      // Add new product to cart
      _items.add(CartItem(product: product, quantity: 1));
    }

    // Save cart to shared preferences
    _saveCart();
  }

  // Method to update quantity
  void updateQuantity(Product product, int newQuantity) {
    final index =
        _items.indexWhere((item) => item.product.name == product.name);

    if (index >= 0) {
      if (newQuantity <= 0) {
        // Remove item if quantity is 0 or less
        _items.removeAt(index);
      } else {
        // Update quantity
        _items[index].quantity = newQuantity;
      }

      // Save cart to shared preferences
      _saveCart();
    }
  }

  // Method to clear cart
  void clearCart() {
    _items.clear();
    _saveCart();
  }

  // Save cart to SharedPreferences
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(_items.map((item) => item.toMap()).toList());
      await prefs.setString('cart', cartJson);
    } catch (e) {
      print('Error saving cart: $e');
    }
  }

  // Load cart from SharedPreferences
  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString('cart');

      if (cartJson != null) {
        final List<dynamic> cartData = jsonDecode(cartJson);
        _items = cartData.map((data) => CartItem.fromMap(data)).toList();
      }
    } catch (e) {
      print('Error loading cart: $e');
    }
  }

  void removeAllFromCart(Product product) {}

  void clear() {}
}
