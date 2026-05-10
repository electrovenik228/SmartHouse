class ActionLog {
  final int id;
  final int? userId;
  final int deviceId;
  final String action;
  final DateTime createdAt;

  const ActionLog({
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.action,
    required this.createdAt,
  });

  factory ActionLog.fromJson(Map<String, dynamic> json) => ActionLog(
        id: json['id'] as int,
        userId: json['user_id'] as int?,
        deviceId: json['device_id'] as int,
        action: json['action'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
