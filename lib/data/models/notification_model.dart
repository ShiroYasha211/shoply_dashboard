import 'user_model.dart';

class NotificationModel {
  final String id;
  final String? userId;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final Profile? user;

  NotificationModel({
    required this.id,
    this.userId,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.user,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      userId: json['user_id'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      user: json['user'] != null ? Profile.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isGeneral => userId == null;
  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);

    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}
