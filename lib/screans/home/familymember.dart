import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:updated_smart_home/core/helps%20functions/getUserData.dart';
import 'package:updated_smart_home/services/ha-api.dart';

/// ===================== MODELS =====================

class User {
  final String id;
  final String name;
  final String role;
  final String password;
  final String adminId;
  final String haUrl;
  final String haToken;
  final List<String> allowedEntities;

  User({
    required this.id,
    required this.name,
    required this.role,
    required this.password,
    required this.adminId,
    required this.haUrl,
    required this.haToken,
    required this.allowedEntities,
  });

  factory User.fromMap(Map<String, dynamic> map, String id) {
    return User(
      id: id,
      name: map['name'] ?? '',
      role: map['role'] ?? 'user',
      password: map['password'] ?? '',
      adminId: map['adminId'] ?? '',
      haUrl: map['haUrl'] ?? '',
      haToken: map['haToken'] ?? '',
      allowedEntities: List<String>.from(map['allowedEntities'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
      'password': password,
      'adminId': adminId,
      'haUrl': haUrl,
      'haToken': haToken,
      'allowedEntities': allowedEntities,
    };
  }
}

class HAEntity {
  final String id;
  final String name;

  HAEntity({required this.id, required this.name});

  factory HAEntity.fromMap(Map<String, dynamic> map) {
    return HAEntity(
      id: map['entity_id'] ?? '',
      name: map['attributes']?['friendly_name'] ?? map['entity_id'] ?? '',
    );
  }
}

/// ===================== PAGE =====================

class UsersManagementPage extends StatefulWidget {
  const UsersManagementPage({super.key});

  @override
  _UsersManagementPageState createState() => _UsersManagementPageState();
}

class _UsersManagementPageState extends State<UsersManagementPage> {
  List<User> users = [];
  bool isLoading = true;

  final Color primaryColor = const Color(0xff5857aa);

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  /// ===================== FETCH USERS =====================
  Future<void> fetchUsers() async {
    try {
      setState(() => isLoading = true);

      final currentAdminId = getUser().uid;

      final snapshot = await FirebaseFirestore.instance
          .collection('members')
          .where('adminId', isEqualTo: currentAdminId)
          .get();

      users = snapshot.docs
          .map((doc) => User.fromMap(doc.data(), doc.id))
          .toList();

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching users: $e')));
    }
  }

  /// ===================== ADD / EDIT USER =====================
  Future<void> _openUserDialog({User? user}) async {
    final nameController = TextEditingController(text: user?.name ?? '');
    final passwordController = TextEditingController(
      text: user?.password ?? '',
    );
    final role = user?.role ?? 'user';
    List<String> selectedEntities = user?.allowedEntities ?? [];

    bool isFetchingEntities = true;
    List<HAEntity> allEntities = [];

    try {
      final rawEntities = await HomeAssistantApi.getStates();
      allEntities = rawEntities.map((e) => HAEntity.fromMap(e)).toList();
      isFetchingEntities = false;
    } catch (e) {
      isFetchingEntities = false;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching devices: $e')));
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                user == null ? 'Add User' : 'Edit User',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              content: isFetchingEntities
                  ? const SizedBox(
                      height: 120,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password / Code',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Allowed Devices',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: allEntities.map((entity) {
                              final isSelected = selectedEntities.contains(
                                entity.id,
                              );
                              return ChoiceChip(
                                label: Text(entity.name),
                                selected: isSelected,
                                selectedColor: primaryColor.withOpacity(0.2),
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? primaryColor
                                      : Colors.black,
                                ),
                                onSelected: (selected) {
                                  setStateDialog(() {
                                    if (selected) {
                                      selectedEntities.add(entity.id);
                                    } else {
                                      selectedEntities.remove(entity.id);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xff5857aa)),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final newUser = User(
                      id: user?.id ?? '',
                      name: nameController.text,
                      password: passwordController.text,
                      role: role,
                      adminId: getUser().uid,
                      haUrl: getUser().ha_url,
                      haToken: getUser().ha_token,
                      allowedEntities: selectedEntities,
                    );

                    if (user == null) {
                      await FirebaseFirestore.instance
                          .collection('members')
                          .add(newUser.toMap());
                    } else {
                      await FirebaseFirestore.instance
                          .collection('members')
                          .doc(user.id)
                          .update(newUser.toMap());
                    }

                    Navigator.pop(context);
                    fetchUsers();
                  },
                  child: Text(user == null ? 'Add User' : 'Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// ===================== DELETE USER =====================
  Future<void> _deleteUser(User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Delete User',
          style: TextStyle(color: Color(0xff5857aa)),
        ),
        content: Text('Are you sure you want to delete ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xff5857aa)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('members')
          .doc(user.id)
          .delete();
      fetchUsers();
    }
  }

  /// ===================== USER CARD =====================
  Widget _buildUserTile(User user) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: primaryColor,
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Role: ${user.role}',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: primaryColor),
              onPressed: () => _openUserDialog(user: user),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteUser(user),
            ),
          ],
        ),
      ),
    );
  }

  /// ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        centerTitle: true,
        title: const Text(
          'Users Management',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _openUserDialog(),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
          ? const Center(
              child: Text(
                'No users added yet',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: users.map(_buildUserTile).toList()),
            ),
    );
  }
}
