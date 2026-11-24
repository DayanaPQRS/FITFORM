class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? avatar;
  final double? heightCm;
  final double? weightKg;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
    this.heightCm,
    this.weightKg,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      avatar: json['avatar'],
      heightCm: json['height_cm'] != null
          ? double.tryParse(json['height_cm'].toString())
          : null,
      weightKg: json['weight_kg'] != null
          ? double.tryParse(json['weight_kg'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'avatar': avatar,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
    };
  }
}
