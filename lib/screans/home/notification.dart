import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String message;
  final String userName;
  final DateTime timestamp;

  AppNotification({
    required this.id,
    required this.message,
    required this.userName,
    required this.timestamp,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      message: data['message'] ?? '',
      userName: data['userName'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'message': message,
    'userName': userName,
    'timestamp': Timestamp.fromDate(timestamp),
  };
}
