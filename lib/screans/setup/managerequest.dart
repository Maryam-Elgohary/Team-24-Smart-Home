import 'package:flutter/material.dart';
import 'package:updated_smart_home/services/ha-api.dart';

class ManageRequestsPage extends StatefulWidget {
  const ManageRequestsPage({super.key});

  @override
  _ManageRequestsPageState createState() => _ManageRequestsPageState();
}

class _ManageRequestsPageState extends State<ManageRequestsPage> {
  List<Map<String, dynamic>> requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    try {
      setState(() {
        isLoading = true;
      });
      final fetchedRequests = await HomeAssistantApi.getPendingRequests();
      setState(() {
        requests = fetchedRequests;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching requests: $e')));
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> approveRequest(String requestId) async {
    try {
      final result = await HomeAssistantApi.approveRequest(requestId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'])));
      fetchRequests(); // تحديث القايمة بعد الموافقة
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error approving request: $e')));
    }
  }

  Future<void> declineRequest(String requestId) async {
    try {
      final result = await HomeAssistantApi.declineRequest(requestId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'])));
      fetchRequests(); // تحديث القايمة بعد الرفض
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error declining request: $e')));
    }
  }

  Widget _buildRequestTile(Map<String, dynamic> request) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Name: ${request['name']}',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                Text(
                  'Email: ${request['email']}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  'Role: ${request['role']}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  'Date: ${request['date']}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        declineRequest(request['id']);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () {
                        approveRequest(request['id']);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Expanded(
                    child: Text(
                      "Manage requests",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // للحفاظ على التوازن
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : requests.isEmpty
                    ? const Center(
                        child: Text(
                          "No pending requests at the moment.",
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: requests
                              .map((request) => _buildRequestTile(request))
                              .toList(),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
