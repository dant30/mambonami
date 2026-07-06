// mobile/lib/data/models/user.dart
class UserModel {
  final int? id;
  final String? uuid;
  final String? phone;
  final String? username;
  final String? email;
  final String? role;
  final String? fullName;
  final String? displayName;
  final String? avatarUrl;
  final String? location;
  final String? bio;
  final bool isVerified;
  final String? farmName;
  final String? businessName;
  final String? vehicleType;
  final String? mpesaNumber;

  UserModel({
    this.id,
    this.uuid,
    this.phone,
    this.username,
    this.email,
    this.role,
    this.fullName,
    this.displayName,
    this.avatarUrl,
    this.location,
    this.bio,
    this.isVerified = false,
    this.farmName,
    this.businessName,
    this.vehicleType,
    this.mpesaNumber,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      uuid: json['uuid']?.toString(),
      phone: json['phone']?.toString(),
      username: json['username']?.toString(),
      email: json['email']?.toString(),
      role: json['role']?.toString(),
      fullName: _coerceString(json['full_name'] ?? json['fullName'] ?? json['display_name'] ?? json['displayName']),
      displayName: _coerceString(json['display_name'] ?? json['displayName']),
      avatarUrl: _coerceString(json['avatar_url'] ?? json['avatarUrl'] ?? json['photo_url'] ?? json['photoUrl']),
      location: _coerceString(json['location'] ?? json['address'] ?? json['city']),
      bio: _coerceString(json['bio'] ?? json['about']),
      isVerified: _coerceBool(json['is_verified'] ?? json['isVerified']),
      farmName: _coerceString(json['farm_name'] ?? json['farmName']),
      businessName: _coerceString(json['business_name'] ?? json['businessName']),
      vehicleType: _coerceString(json['vehicle_type'] ?? json['vehicleType']),
      mpesaNumber: _coerceString(json['mpesa_number'] ?? json['mpesaNumber'] ?? json['paybill_number'] ?? json['paybillNumber']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'phone': phone,
        'username': username,
        'email': email,
        'role': role,
        'full_name': fullName,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'location': location,
        'bio': bio,
        'is_verified': isVerified,
        'farm_name': farmName,
        'business_name': businessName,
        'vehicle_type': vehicleType,
        'mpesa_number': mpesaNumber,
      };

  String get primaryName => (displayName ?? fullName ?? username ?? phone ?? '').trim();
}

String? _coerceString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

bool _coerceBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == '1' || normalized == 'true' || normalized == 'yes' || normalized == 'y';
  }
  return false;
}
