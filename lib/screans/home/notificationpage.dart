import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class Notificationpage extends StatelessWidget {
  final String adminID;
  const Notificationpage({super.key, required this.adminID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No notifications yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final time = doc['timestamp']?.toDate();

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text(doc['message']),
                  subtitle: time != null
                      ? Text(
                          "${timeago.format(time)} - ${doc['user']}",
                          style: const TextStyle(color: Colors.grey),
                        )
                      : Text(doc['user']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

Future<void> sendNotification({
  required String user,
  required String message,
  required String adminID,
}) async {
  await FirebaseFirestore.instance.collection('notifications').add({
    'user': user,
    'adminID': adminID,
    'message': message,
    'timestamp': FieldValue.serverTimestamp(), // الوقت الحالي
  });
}

Future<int> getAdminNotificationCount(String adminId) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('adminID', isEqualTo: adminId) // فلترة على الاسم أو أي ID
        .get();

    return querySnapshot.docs.length;
  } catch (e) {
    print("Error fetching notification count: $e");
    return 0;
  }
}
