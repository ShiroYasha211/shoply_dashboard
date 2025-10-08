// models/profile_model.dart
class Profile {
  final String id;
  final String? fullName;
  final String? phone;
  final String? avatarUrl;
  final String? address;
  final DateTime createdAt;
  final String role;
  final String status;
  final String email;

  Profile({
    required this.id,
    this.fullName,
    this.phone,
    this.avatarUrl,
    this.address,
    required this.createdAt,
    required this.role,
    required this.status,
    required this.email,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] ?? '',
      fullName: json['full_name'],
      phone: json['phone'],
      avatarUrl: json['avatar_url'],
      address: json['address'],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      role: json['role'] ?? 'customer',
      status: json['status'] ?? 'active',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'address': address,
      'created_at': createdAt.toIso8601String(),
      'role': role,
      'status': status,
      'email': email,
    };
  }

  Profile copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? address,
    DateTime? createdAt,
    String? role,
    String? status,
    String? email,
  }) {
    return Profile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
      status: status ?? this.status,
      email: email ?? this.email,
    );
  }
}
