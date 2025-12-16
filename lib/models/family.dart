class FamilyMember {
  final String id;
  final String name;
  final String role; // Admin, Member, Guest
  final String lastLogin;
  final String lastActivity;

  FamilyMember({
    required this.id,
    required this.name,
    required this.role,
    required this.lastLogin,
    required this.lastActivity,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      role: json['role'] ?? 'Member',
      lastLogin: json['lastLogin'] ?? '',
      lastActivity: json['lastActivity'] ?? '',
    );
  }
}