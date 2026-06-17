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
      uuid: json['uuid']?.toString() ?? '',
      orderUuid: json['order_uuid']?.toString() ?? json['order']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'open',
      resolution: json['resolution']?.toString(),
      attachmentUrls: _parseAttachments(json['attachments']),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      resolvedAt: json['resolved_at'] != null ? DateTime.tryParse(json['resolved_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
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
