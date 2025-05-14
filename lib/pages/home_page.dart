import 'dart:convert';
import 'dart:io';

import 'package:craft/models/product.dart';
import 'package:craft/pages/chat_page.dart';
import 'package:craft/pages/product_details_page.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: unused_import
import 'add_product_page.dart';
// Import the cart page
import 'cart_page.dart';
// Import the favorites page
import 'favourites_page.dart';

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

class HomePage extends StatefulWidget {
  // ignore: use_super_parameters
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedCategoryIndex = 0;
  int _currentIndex = 0;
  final List<String> _categories = [
    'All',
    'Arts & Crafts',
    'Pots & Plants',
    'Kitchen & Dining'
  ];

  // List to store cart items
  List<CartItem> _cartItems = [];

  // List to store all products
  List<Product> _products = [
    Product(
        name: 'Handmade Basket',
        price: 500.00,
        description: 'Beautiful handmade basket for home decor',
        category: 'Arts & Crafts',
        imagePath: 'assets/basket.jpg'),
    Product(
        name: 'Ceramic Pot',
        price: 750.00,
        description: 'Handcrafted ceramic pot for plants',
        category: 'Pots & Plants',
        imagePath: 'assets/pottery.jpg'),
  ];

  // List to store favorite products
  List<Product> _favoriteProducts = [];

  // Search controller and query
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadFavorites();
    _loadCart();
    // Add listener to search controller
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Method to handle search query changes
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  // Method to add product to cart
  void _addToCart(Product product) {
    setState(() {
      // Check if product already exists in cart
      final existingItemIndex = _cartItems.indexWhere(
        (item) => item.product.name == product.name,
      );

      if (existingItemIndex >= 0) {
        // Increment quantity if product already in cart
        _cartItems[existingItemIndex].quantity += 1;
      } else {
        // Add new product to cart
        _cartItems.add(CartItem(product: product, quantity: 1));
      }
    });

    // Save cart to shared preferences
    _saveCart();
    _showSnackBar('${product.name} added to cart');
  }

  // Save cart to SharedPreferences
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson =
          jsonEncode(_cartItems.map((item) => item.toMap()).toList());
      await prefs.setString('cart', cartJson);
    } catch (e) {
      _showSnackBar('Error saving cart: $e');
    }
  }

  // Load cart from SharedPreferences
  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString('cart');

      if (cartJson != null) {
        final List<dynamic> cartData = jsonDecode(cartJson);
        setState(() {
          _cartItems = cartData.map((data) => CartItem.fromMap(data)).toList();
        });
      }
    } catch (e) {
      _showSnackBar('Error loading cart: $e');
    }
  }

  // Load products from SharedPreferences
  Future<void> _loadProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = prefs.getString('products');

      if (productsJson != null) {
        final List<dynamic> productsData = jsonDecode(productsJson);
        final List<Product> loadedProducts =
            productsData.map((data) => Product.fromJson(data)).toList();

        // Only replace default products if we have saved products
        if (loadedProducts.isNotEmpty) {
          setState(() {
            _products = loadedProducts;
          });
        }
      }
    } catch (e) {
      _showSnackBar('Error loading products: $e');
    }
  }

  // Load favorites from SharedPreferences
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString('favorites');

      if (favoritesJson != null) {
        final List<dynamic> favoritesData = jsonDecode(favoritesJson);

        setState(() {
          // First load all products, then identify favorites by name
          _favoriteProducts = [];

          for (var favData in favoritesData) {
            final Product favorite = Product.fromJson(favData);

            // Check if this favorite exists in products
            final existingProduct = _products.firstWhere(
              (p) => p.name == favorite.name,
              orElse: () => favorite, // Add to products if not found
            );

            _favoriteProducts.add(existingProduct);
          }
        });
      }
    } catch (e) {
      _showSnackBar('Error loading favorites: $e');
    }
  }

  // Save products to SharedPreferences
  Future<void> _saveProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = jsonEncode(_products.map((p) => p.toMap()).toList());
      await prefs.setString('products', productsJson);
    } catch (e) {
      _showSnackBar('Error saving products: $e');
    }
  }

  // Save favorites to SharedPreferences
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson =
          jsonEncode(_favoriteProducts.map((p) => p.toMap()).toList());
      await prefs.setString('favorites', favoritesJson);
    } catch (e) {
      _showSnackBar('Error saving favorites: $e');
    }
  }

  // Method to add a new product to the list
  void _addProduct(Product product) async {
    // If image is from camera/gallery, copy it to app's documents directory
    if (!product.imagePath.startsWith('assets/')) {
      try {
        final newPath = await _saveImageToAppDirectory(product.imagePath);
        product = product.copyWith(imagePath: newPath);
      } catch (e) {
        _showSnackBar('Error saving image: $e');
      }
    }

    setState(() {
      _products.add(product);
    });

    // Save updated products list
    _saveProducts();
    _showSnackBar('Product added successfully');
  }

  // Save an image to app's documents directory for persistence
  Future<String> _saveImageToAppDirectory(String originalPath) async {
    final File originalFile = File(originalPath);
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String fileName = originalPath.split('/').last;
    final String newPath = '${appDir.path}/$fileName';

    // Copy the file to app's documents directory
    await originalFile.copy(newPath);
    return newPath;
  }

  // Method to toggle favorite status
  void _toggleFavorite(Product product) {
    setState(() {
      if (_favoriteProducts.contains(product)) {
        _favoriteProducts.remove(product);
        _showSnackBar('Removed from favorites');
      } else {
        _favoriteProducts.add(product);
        _showSnackBar('Added to favorites');
      }
    });

    // Save updated favorites list
    _saveFavorites();
  }

  // Method to remove from favorites
  void _removeFromFavorites(Product product) {
    setState(() {
      _favoriteProducts.remove(product);
      _showSnackBar('Removed from favorites');
    });

    // Save updated favorites list
    _saveFavorites();
  }

  // Show a snackbar with message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
        backgroundColor: Colors.black,
      ),
    );
  }

  // Filter products based on selected category and search query
  List<Product> get _filteredProducts {
    // First filter by category
    List<Product> categoryFiltered = _selectedCategoryIndex == 0
        ? _products
        : _products
            .where((product) =>
                product.category == _categories[_selectedCategoryIndex])
            .toList();

    // Then filter by search query if one exists
    if (_searchQuery.isNotEmpty) {
      return categoryFiltered
          .where((product) =>
              product.name.toLowerCase().contains(_searchQuery) ||
              product.description.toLowerCase().contains(_searchQuery) ||
              product.category.toLowerCase().contains(_searchQuery))
          .toList();
    }

    return categoryFiltered;
  }

  // Method to clear search
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _getBodyForIndex(),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _getBodyForIndex() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return FavoritesPage(
          favoriteProducts: _favoriteProducts,
          onRemoveFromFavorites: _removeFromFavorites,
        );
      case 3:
        return const ChatPage();
      default:
        return Container();
    }
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Find Your',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Favourite Handmade',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),

            // Search Bar
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'search here...',
                              border: InputBorder.none,
                              hintStyle: const TextStyle(color: Colors.grey),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear,
                                          color: Colors.grey),
                                      onPressed: _clearSearch,
                                    )
                                  : null,
                            ),
                            onSubmitted: (value) {
                              setState(() {
                                _searchQuery = value.toLowerCase();
                              });
                            },
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 6,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.search, color: Colors.black),
                            onPressed: () {
                              // Focus node no longer needed since we have controller
                              FocusScope.of(context).unfocus();
                              setState(() {
                                _searchQuery =
                                    _searchController.text.toLowerCase();
                              });
                            },
                            padding: EdgeInsets.zero,
                            iconSize: 24,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined,
                            color: Colors.black),
                        onPressed: () {
                          // Navigate to Cart Page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CartPage(),
                            ),
                          ).then((_) {
                            // Refresh state when returning from cart page
                            setState(() {});
                            _loadCart();
                          });
                        },
                      ),
                      if (_cartItems.isNotEmpty)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${_cartItems.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Easter Sale Banner
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
                image: const DecorationImage(
                  image: AssetImage('assets/easter_banner.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Easter',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[800],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'SALE',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '50% OFF',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink[400],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'LIMITED TIME ONLY',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Categories
            SizedBox(
              height: 35,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryIndex = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: _selectedCategoryIndex == index
                            ? Colors.black
                            : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _categories[index],
                          style: TextStyle(
                            color: _selectedCategoryIndex == index
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Search results text
            if (_searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Text(
                      'Results for "${_searchController.text}"',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_filteredProducts.length} found',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

            // Products Grid
            Expanded(
              child: _filteredProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          _searchQuery.isNotEmpty
                              ? Text(
                                  'No products matching "${_searchController.text}"',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                )
                              : const Text(
                                  'No products in this category',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return _buildProductCard(
                          product,
                          'Rs.${product.price.toStringAsFixed(2)}',
                          product.name,
                          index % 2 == 1,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 206, 206, 206),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 20,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                Icons.home,
                size: 28,
                color: _currentIndex == 0 ? Colors.black : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _currentIndex = 0;
                });
              },
            ),
            IconButton(
              icon: Icon(
                Icons.favorite_border,
                size: 28,
                color: _currentIndex == 1 ? Colors.black : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _currentIndex = 1;
                });
              },
            ),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 2 ? Colors.black : Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.add,
                  size: 28,
                  color: _currentIndex == 2 ? Colors.white : Colors.black,
                ),
              ),
              onPressed: () {
                // Navigate to Add Product Page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddProductPage(onProductAdded: _addProduct),
                  ),
                );
              },
            ),
            Stack(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.chat_bubble_outline,
                    size: 28,
                    color: _currentIndex == 3 ? Colors.black : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _currentIndex = 3;
                    });
                  },
                ),
                // Notification dot (only show if there are unread messages)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            Stack(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.shopping_cart_outlined,
                    size: 28,
                    color: _currentIndex == 4 ? Colors.black : Colors.grey,
                  ),
                  onPressed: () {
                    // Navigate to Cart Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CartPage(),
                      ),
                    ).then((_) {
                      // Refresh state when returning from cart page
                      setState(() {});
                      _loadCart();
                    });
                  },
                ),
                // Cart item count badge
                if (_cartItems.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${_cartItems.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            IconButton(
              icon: Icon(
                Icons.person_outline,
                size: 28,
                color: _currentIndex == 5 ? Colors.black : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _currentIndex = 5;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(
      Product product, String price, String name, bool isRightAligned) {
    final bool isFavorite = _favoriteProducts.contains(product);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE1EFDA),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildProductImage(product.imagePath),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _toggleFavorite(product),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red[400] : Colors.black,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price, // This displays the customer-set price
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to Product Details Page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailsPage(product: product),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text('View'),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _addToCart(product),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text('Add'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build product image based on path type
  Widget _buildProductImage(String imagePath) {
    try {
      // For asset images
      if (imagePath.startsWith('assets/')) {
        return Image.asset(
          imagePath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.image_not_supported, size: 64);
          },
        );
      }
      // For network images (from a database/storage like Appwrite)
      else if (imagePath.startsWith('http://') ||
          imagePath.startsWith('https://')) {
        return Image.network(
          imagePath,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.broken_image, size: 64);
          },
        );
      }
      // For local file images
      else {
        final file = File(imagePath);
        return Image.file(
          file,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.image_not_supported, size: 64);
          },
        );
      }
    } catch (e) {
      return const Icon(Icons.image_not_supported, size: 64);
    }
  }
}
