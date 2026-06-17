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
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      uuid: json['uuid']?.toString(),
      phone: json['phone']?.toString(),
      username: json['username']?.toString(),
      email: json['email']?.toString(),
      role: json['role']?.toString(),
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