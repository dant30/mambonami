// mobile/lib/data/dtos/trip_dto.dart
class TripPickupDto {
  final double? latitude;
  final double? longitude;
  final String? photoPath;

  TripPickupDto({this.latitude, this.longitude, this.photoPath});

  Map<String, dynamic> toJson() => {
        if (latitude != null) 'pickup_lat': latitude,
        if (longitude != null) 'pickup_lng': longitude,
        if (photoPath != null) 'pickup_photo': photoPath,
      };
}

class TripDeliveryDto {
  final double? latitude;
  final double? longitude;
  final String? photoPath;

  TripDeliveryDto({this.latitude, this.longitude, this.photoPath});

  Map<String, dynamic> toJson() => {
        if (latitude != null) 'delivery_lat': latitude,
        if (longitude != null) 'delivery_lng': longitude,
        if (photoPath != null) 'delivery_photo': photoPath,
      };
}

class GenerateOtpResponse {
  final String otp;
  final int expiresIn;

  GenerateOtpResponse({required this.otp, required this.expiresIn});

  factory GenerateOtpResponse.fromJson(Map<String, dynamic> json) {
    return GenerateOtpResponse(
      otp: json['otp'],
      expiresIn: json['expires_in'],
    );
  }
}

class VerifyOtpRequest {
  final String otp;

  VerifyOtpRequest(this.otp);

  Map<String, dynamic> toJson() => {'otp': otp};
}

class TripArriveResponse {
  final String message;
  final DateTime? arrivedAt;
  final int? waitingGraceMinutes;

  TripArriveResponse(
      {required this.message, this.arrivedAt, this.waitingGraceMinutes});

  factory TripArriveResponse.fromJson(Map<String, dynamic> json) {
    return TripArriveResponse(
      message: json['message']?.toString() ?? '',
      arrivedAt: json['arrived_at'] != null
          ? DateTime.parse(json['arrived_at'])
          : null,
      waitingGraceMinutes: json['waiting_grace_minutes'] as int?,
    );
  }
}
