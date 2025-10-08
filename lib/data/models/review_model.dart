import 'user_model.dart';
import 'product_model.dart';

class Review {
  final String id;
  final String userId;
  final String productId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final Profile? user;
  final ProductModel? product;

  Review({
    required this.id,
    required this.userId,
    required this.productId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.user,
    this.product,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      userId: json['user_id'],
      productId: json['product_id'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
      user: json['user'] != null ? Profile.fromJson(json['user']) : null,
      product: json['product'] != null
          ? ProductModel.fromJson(json['product'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isPositive => rating >= 4;
  bool get isNegative => rating <= 2;
  String get ratingDescription {
    switch (rating) {
      case 1:
        return 'سيئ جداً';
      case 2:
        return 'سيئ';
      case 3:
        return 'مقبول';
      case 4:
        return 'جيد';
      case 5:
        return 'ممتاز';
      default:
        return 'غير محدد';
    }
  }
}
