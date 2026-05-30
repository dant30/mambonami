// mobile/lib/data/dtos/auth_dto.dart
class AuthDto {
  final Map<String, dynamic> user;
  final Map<String, dynamic>? tokens;

  AuthDto({required this.user, this.tokens});

  factory AuthDto.fromJson(Map<String, dynamic> json) {
    return AuthDto(
      user: json['user'] as Map<String, dynamic>? ?? {},
      tokens: json['tokens'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'user': user,
        'tokens': tokens,
      };
}
// mobile/lib/data/dtos/auth_dto.dart