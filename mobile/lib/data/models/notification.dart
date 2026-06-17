class NotificationModel {
  final int id;
  final String uuid;
  final String channel;
  final String title;
  final String body;
  final Map<String, dynamic> metadata;
  final String status; // pending, sent, failed, read
  final DateTime createdAt;
  final DateTime? readAt;

  NotificationModel({
    required this.id,
    required this.uuid,
    required this.channel,
    required this.title,
    required this.body,
    required this.metadata,
    required this.status,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      uuid: json['uuid']?.toString() ?? '',
      channel: json['channel']?.toString() ?? 'push',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      metadata: json['metadata'] is Map<String, dynamic>
          ? json['metadata'] as Map<String, dynamic>
          : json['metadata'] is Map
              ? Map<String, dynamic>.from(json['metadata'] as Map)
              : <String, dynamic>{},
      status: json['status']?.toString() ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'uuid': uuid,
    'channel': channel,
    'title': title,
    'body': body,
    'metadata': metadata,
    'status': status,
    'created_at': createdAt.toIso8601String(),
    'read_at': readAt?.toIso8601String(),
  };

  bool get isRead => status == 'read';
  bool get isUnread => !isRead;
}
