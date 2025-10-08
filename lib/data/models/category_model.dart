class Category {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<Subcategory>? subcategories;

  Category({
    required this.id,
    required this.name,
    required this.createdAt,
    this.subcategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      subcategories: json['subcategories'] != null
          ? (json['subcategories'] as List)
                .map((sub) => Subcategory.fromJson(sub))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'subcategories': subcategories?.map((sub) => sub.toJson()).toList(),
    };
  }
}

class Subcategory {
  final String id;
  final String categoryId;
  final String name;
  final DateTime createdAt;

  Subcategory({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.createdAt,
  });

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      id: json['id'] ?? '',
      categoryId: json['category_id'] ?? '',
      name: json['name'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
