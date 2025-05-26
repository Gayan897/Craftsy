class Product {
  final String name;
  final double price; // Keep as double in the model for flexibility
  final String description;
  final String category;
  final String imagePath;
  final DateTime? createdAt;
  String imageUrl;

  var size; // This field needs initialization

  Product({
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.imagePath,
    this.createdAt,
  }) : imageUrl = imagePath; // Initialize imageUrl with imagePath

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price.toInt(), // Convert to integer for Appwrite
      'description': description,
      'category': category,
      'imageUrl': imagePath,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // For backward compatibility with the code
  Map<String, dynamic> toJson() => toMap();

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] ?? '',
      price: (json['price'] ?? 0)
          .toDouble(), // Convert back to double when reading
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      imagePath: json['imageUrl'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Product copyWith({
    String? name,
    double? price,
    String? description,
    String? category,
    String? imagePath,
    DateTime? createdAt,
  }) {
    return Product(
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}
