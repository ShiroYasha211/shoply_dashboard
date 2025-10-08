// models/product_model.dart
class ProductModel {
  final String id;
  final String? subcategoryId;
  final String name;
  final String? description;
  final double price;
  final int stockQuantity;
  final String? imageUrl;
  final DateTime createdAt;
  final String? categoryName;
  final String? subcategoryName;

  ProductModel({
    required this.id,
    this.subcategoryId,
    required this.name,
    this.description,
    required this.price,
    this.stockQuantity = 0,
    this.imageUrl,
    required this.createdAt,
    this.categoryName,
    this.subcategoryName,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      subcategoryId: json['subcategory_id'],
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stockQuantity: json['stock_quantity'] ?? 0,
      imageUrl: json['image_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      categoryName: json['category_name'] ?? json['categories']?['name'],
      subcategoryName:
          json['subcategory_name'] ?? json['subcategories']?['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subcategory_id': subcategoryId,
      'name': name,
      'description': description,
      'price': price,
      'stock_quantity': stockQuantity,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // For Supabase insert/update (without id and created_at)
  Map<String, dynamic> toSupabaseJson() {
    return {
      'subcategory_id': subcategoryId,
      'name': name,
      'description': description,
      'price': price,
      'stock_quantity': stockQuantity,
      'image_url': imageUrl,
    };
  }

  ProductModel copyWith({
    String? id,
    String? subcategoryId,
    String? name,
    String? description,
    double? price,
    int? stockQuantity,
    String? imageUrl,
    DateTime? createdAt,
    String? categoryName,
    String? subcategoryName,
  }) {
    return ProductModel(
      id: id ?? this.id,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      categoryName: categoryName ?? this.categoryName,
      subcategoryName: subcategoryName ?? this.subcategoryName,
    );
  }

  bool get isInStock => stockQuantity > 0;
  bool get isLowStock => stockQuantity <= 10 && stockQuantity > 0;
  bool get isOutOfStock => stockQuantity == 0;
}
