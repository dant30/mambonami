class VerificationDocument {
  final String uuid;
  final String type;
  final String status;
  final String? fileUrl;
  final DateTime createdAt;
  final DateTime? reviewedAt;

  VerificationDocument({
    required this.uuid,
    required this.type,
    required this.status,
    this.fileUrl,
    required this.createdAt,
    this.reviewedAt,
  });

  factory VerificationDocument.fromJson(Map<String, dynamic> json) {
    return VerificationDocument(
      uuid: json['uuid']?.toString() ?? '',
      type: json['type']?.toString() ?? json['document_type']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      fileUrl: json['file_url']?.toString() ?? json['file']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      reviewedAt: json['reviewed_at'] != null ? DateTime.tryParse(json['reviewed_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'type': type,
        'status': status,
        'file_url': fileUrl,
        'created_at': createdAt.toIso8601String(),
        'reviewed_at': reviewedAt?.toIso8601String(),
      };
}
