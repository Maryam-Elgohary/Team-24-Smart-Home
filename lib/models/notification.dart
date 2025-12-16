class Notification {
  final String id;
  final String userId;
  final String message;
  final DateTime timestamp;

  Notification({
    required this.id,
    required this.userId,
    required this.message,
    required this.timestamp,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      userId: json['user_id'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}