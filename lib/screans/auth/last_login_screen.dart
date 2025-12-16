import 'package:flutter/material.dart';

// Mock database to store and manage login entries
class MockLoginDatabase {
  static final List<Map<String, dynamic>> _logins = [];

  // Add a new login entry
  static Future<void> addLogin({
    required String name,
    required String role,
    required String activity,
    required String time,
    bool hasError = false,
  }) async {
    // Simulate database write
    await Future.delayed(const Duration(milliseconds: 500));
    _logins.add({
      'name': name,
      'role': role,
      'activity': activity,
      'time': time,
      'hasError': hasError,
    });
  }

  // Fetch all login entries
  static Future<List<Map<String, dynamic>>> fetchLastLogins() async {
    // Simulate database read
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_logins);
  }
}

class LastLoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Last Login',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: MockLoginDatabase.fetchLastLogins(), // Fetch data dynamically
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading login data'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No login history yet'));
          }

          final users = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Column(
                children: [
                  Container(
                    width: double.infinity, // Full width
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey[300],
                        child: Text(
                          user['name'][0],
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            user['name'] + ' (${user['role']})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (user['hasError'])
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Activity: ${user['activity']}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            user['time'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (index < users.length - 1) // Add divider except for last item
                    Divider(
                      color: Colors.grey[300],
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}