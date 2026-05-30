// mobile/lib/data/models/user.dart
class UserModel {
  final int? id;
  final String? uuid;
  final String? phone;
  final String? username;
  final String? email;
  final String? role;

  UserModel({this.id, this.uuid, this.phone, this.username, this.email, this.role});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int?,
      uuid: json['uuid'] as String?,
      phone: json['phone'] as String?,
      username: json['username'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'phone': phone,
        'username': username,
        'email': email,
        'role': role,
      };
}
// mobile/lib/data/models/user.dart