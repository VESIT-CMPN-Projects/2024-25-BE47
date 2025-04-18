class User {
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,  // 'NGO' or 'Public'
    required this.createdAt,
    required this.lastActive,
    required this.isOnline,
  });

  late String id;
  late String name;
  late String email;
  late String role; // 'NGO' or 'Public'
  late String createdAt;
  late String lastActive;
  late bool isOnline;

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    name = json['name'] ?? '';
    email = json['email'] ?? '';
    role = json['role'] ?? 'Public'; // Default role
    createdAt = json['created_at'] ?? '';
    lastActive = json['last_active'] ?? '';
    isOnline = json['is_online'] ?? false;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'created_at': createdAt,
      'last_active': lastActive,
      'is_online': isOnline,
    };
  }
}
