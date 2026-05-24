import 'role_model.dart';
import 'address_model.dart';

class User {
  final int? userId;
  final String name;
  final String email;
  final String? phone;
  final int? age;
  final String? gender;
  final int? roleId;
  final int? addressId;
  final DateTime? createdAt;
  
  // Relationships
  final Role? role;
  final Address? address;

  User({
    this.userId,
    required this.name,
    required this.email,
    this.phone,
    this.age,
    this.gender,
    this.roleId,
    this.addressId,
    this.createdAt,
    this.role,
    this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      age: json['age'],
      gender: json['gender'],
      roleId: json['role_id'],
      addressId: json['address_id'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      role: json['role'] != null ? Role.fromJson(json['role']) : null,
      address: json['address'] != null ? Address.fromJson(json['address']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'age': age,
      'gender': gender,
      'role_id': roleId,
      'address_id': addressId,
      // We generally don't send nested objects or created_at back to the server on update
    };
  }
}
