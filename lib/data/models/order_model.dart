import 'user_model.dart';
import 'product_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final double totalPrice;
  final OrderStatus status;
  final DateTime? createdAt;
  final Profile? user;
  final List<OrderItemModel>? items;

  OrderModel({
    required this.id,
    required this.userId,
    required this.totalPrice,
    required this.status,
    this.createdAt,
    this.user,
    this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      status: OrderStatus.fromString(json['status'] ?? 'pending'),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      user: json['profiles'] != null
          ? Profile.fromJson(json['profiles'])
          : null,
      items: json['order_items'] != null
          ? (json['order_items'] as List)
                .map((item) => OrderItemModel.fromJson(item))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'total_price': totalPrice,
      'status': status.value,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toSupabaseJson() {
    final json = toJson();
    json.remove('id');
    json.remove('created_at');
    return json;
  }

  String get statusDisplayName => status.displayName;
  bool get canCancel => status == OrderStatus.pending;
  bool get canShip => status == OrderStatus.pending;
  bool get canDeliver => status == OrderStatus.shipped;
}

class OrderItemModel {
  final String id;
  final String orderId;
  final String productId;
  final int quantity;
  final double price;
  final ProductModel? product;

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    this.product,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] ?? '',
      orderId: json['order_id'] ?? '',
      productId: json['product_id'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      product: json['products'] != null
          ? ProductModel.fromJson(json['products'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
    };
  }

  Map<String, dynamic> toSupabaseJson() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  double get totalPrice => price * quantity;
}

enum OrderStatus {
  pending('pending', 'معلق'),
  shipped('shipped', 'تم الشحن'),
  delivered('delivered', 'تم التسليم'),
  canceled('canceled', 'ملغي');

  const OrderStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.pending,
    );
  }
}
