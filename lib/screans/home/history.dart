import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class HistoryService {
  static final _history = FirebaseFirestore.instance.collection('history');

  static Future<void> add({
    required String message,
    String? entityId,
    String? roomId,
    String type = 'general',
    String user = "Maryam",
  }) async {
    await _history.add({
      'message': message,
      'entityId': entityId,
      'roomId': roomId,
      'type': type,
      'user': user,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('history')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No history yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final docId = doc.id; // مهم للحذف
              final time = doc['timestamp']?.toDate();

              return Dismissible(
                key: Key(docId), // كل عنصر لازم يبقى ليه Key فريد
                direction: DismissDirection.endToStart, // سحب للشمال
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) async {
                  // حذف من Firestore
                  await FirebaseFirestore.instance
                      .collection('history')
                      .doc(docId)
                      .delete();

                  // Optional: SnackBar تأكيد
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('History entry deleted')),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      doc['type'] == 'device'
                          ? Icons.power
                          : Icons.meeting_room,
                    ),
                    title: Text(doc['message']),
                    subtitle: time != null
                        ? Text(
                            timeago.format(time),
                            style: const TextStyle(color: Colors.grey),
                          )
                        : null,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
