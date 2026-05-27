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
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      uuid: json['uuid'],
      channel: json['channel'],
      title: json['title'],
      body: json['body'],
      metadata: json['metadata'] ?? {},
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
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
