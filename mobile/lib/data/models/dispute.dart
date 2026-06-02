import 'package:equatable/equatable.dart';

class Dispute extends Equatable {
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

  const Dispute({
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

  factory Dispute.fromJson(Map<String, dynamic> json) {
    return Dispute(
      uuid: json['uuid'] ?? '',
      orderUuid: json['order_uuid'] ?? json['order'] ?? '',
      subject: json['subject'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'open',
      resolution: json['resolution'],
      attachmentUrls: _parseAttachments(json['attachments']),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      resolvedAt:
          json['resolved_at'] != null ? DateTime.tryParse(json['resolved_at']) : null,
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

  @override
  List<Object?> get props => [uuid, orderUuid, status, createdAt];
}
