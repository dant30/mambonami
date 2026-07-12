/// Dispute DTOs for creating and managing disputes
library;

// ============ CREATE DISPUTE REQUEST ============
class CreateDisputeRequest {
  final String orderUuid;
  final String subject;
  final String description;
  final List<String>? attachmentUrls;

  CreateDisputeRequest({
    required this.orderUuid,
    required this.subject,
    required this.description,
    this.attachmentUrls,
  });

  Map<String, dynamic> toJson() => {
    'order_uuid': orderUuid,
    'subject': subject,
    'description': description,
    if (attachmentUrls != null) 'attachments': attachmentUrls,
  };
}

// ============ DISPUTE RESPONSE ============
class DisputeResponse {
  final String uuid;
  final String orderUuid;
  final String subject;
  final String description;
  final String status;
  final String? resolution;
  final List<String>? attachmentUrls;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final DateTime? updatedAt;

  DisputeResponse({
    required this.uuid,
    required this.orderUuid,
    required this.subject,
    required this.description,
    required this.status,
    this.resolution,
    this.attachmentUrls,
    required this.createdAt,
    this.resolvedAt,
    this.updatedAt,
  });

  factory DisputeResponse.fromJson(Map<String, dynamic> json) {
    return DisputeResponse(
      uuid: json['uuid'] ?? '',
      orderUuid: json['order_uuid'] ?? json['order'] ?? '',
      subject: json['subject'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'open',
      resolution: json['resolution'],
      attachmentUrls: _parseAttachments(json['attachments']),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      resolvedAt: json['resolved_at'] != null ? DateTime.tryParse(json['resolved_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  static List<String>? _parseAttachments(dynamic attachments) {
    if (attachments is List) {
      return attachments.whereType<String>().toList();
    }
    return null;
  }

  bool get isOpen => status == 'open';
  bool get isResolved => status == 'resolved';
  bool get isClosed => status == 'closed';
}

// ============ RESOLVE DISPUTE REQUEST ============
class ResolveDisputeRequest {
  final String uuid;
  final String resolution;

  ResolveDisputeRequest({
    required this.uuid,
    required this.resolution,
  });

  Map<String, dynamic> toJson() => {
    'resolution': resolution,
  };
}
