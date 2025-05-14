import 'dart:io';

import 'package:craft/models/product.dart';
import 'package:flutter/material.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;

  // ignore: use_super_parameters
  const ProductDetailsPage({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with back button and favorite button
                    _buildHeader(),

                    // Product Image
                    _buildProductImage(),

                    // Product details
                    _buildProductDetails(),

                    // Price section
                    _buildPriceSection(),
                  ],
                ),
              ),
            ),

            // Add to Cart button
            _buildAddToCartButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Details text
          const Text(
            'Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Favorite button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : Colors.black,
              ),
              onPressed: () {
                setState(() {
                  _isFavorite = !_isFavorite;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      height: 250,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE1EFDA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: _getImageWidget(),
      ),
    );
  }

  Widget _getImageWidget() {
    // Check image source and return appropriate widget
    if (widget.product.imagePath.startsWith('assets/')) {
      // Asset image
      return Image.asset(
        widget.product.imagePath,
        fit: BoxFit.contain,
      );
    } else if (widget.product.imagePath.startsWith('http://') ||
        widget.product.imagePath.startsWith('https://')) {
      // Network image (from database URL)
      return Image.network(
        widget.product.imagePath,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF4DB6AC)),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 40),
                SizedBox(height: 8),
                Text(
                  "Couldn't load image",
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          );
        },
      );
    } else if (widget.product.imagePath.startsWith('data:image')) {
      // Base64 encoded image (another database format)
      // ignore: unused_local_variable
      final encodedImage = widget.product.imagePath.split(',').last;
      return Image.memory(
        Uri.parse(widget.product.imagePath).data!.contentAsBytes(),
        fit: BoxFit.contain,
      );
    } else {
      // Local file path
      return Image.file(
        File(widget.product.imagePath),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 40),
                SizedBox(height: 8),
                Text(
                  "File not found",
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Widget _buildProductDetails() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.product.description,
            style: TextStyle(
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          // Additional description similar to what's in the image
          Text(
            'This handcrafted ${widget.product.name.toLowerCase()} is made from durable, eco-friendly natural materials, perfect for carrying groceries, organizing household items, or adding a rustic charm to your home decor. Lightweight yet sturdy, its timeless design suits both practical and decorative purposes.',
            style: TextStyle(
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rs.${widget.product.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Add to cart functionality
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.product.name} added to cart'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(10),
              backgroundColor: Colors.black,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4DB6AC),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Add to Cart',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
