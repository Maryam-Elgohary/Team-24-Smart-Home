// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:updated_smart_home/core/helps%20functions/build_snackbar.dart';
import 'package:updated_smart_home/core/helps%20functions/getUserData.dart';
import 'package:updated_smart_home/core/services/get_it.dart';
import 'package:updated_smart_home/screans/auth/login_screen.dart';
import 'package:updated_smart_home/screans/auth/updated/auth/domain/repo/auth_repo.dart';
import 'package:updated_smart_home/screans/auth/updated/auth/presentation/cubits/sign_out/signout_cubit.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = getUser().name; // القيمة الديفولت
  String userRole = "Admin"; // القيمة الديفولت
  String userImageUrl =
      "https://thaka.bing.com/th?q=Profile+Logo+Cute&w=120&h=120&c=1&rs=1&qlt=70&o=7&cb=1&dpr=1.5&pid=InlineBlock&rm=3&mkt=en-XA&cc=EG&setlang=en&adlt=strict&t=1&mw=247"; // القيمة الديفولت

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    // Placeholder لجلب بيانات المستخدم من API أو قاعدة بيانات
    // هنا ممكن تستبدلي ببيانات حقيقية من Home Assistant أو Firebase أو غيره
    try {
      // مثال: جلب بيانات المستخدم
      // final response = await http.get(...);
      // userName = response.data['name'];
      // userRole = response.data['role'];
      // userImageUrl = response.data['imageUrl'];

      // لو مفيش بيانات، هتفضل القيم الديفولت
      setState(() {
        // userName = "John Smith"; // لو مفيش بيانات، القيمة الديفولت
        // userRole = "Admin";
        // userImageUrl = "https://example.com/user.jpg";
      });
    } catch (e) {
      print("Error fetching user data: $e");
      // لو حصل خطأ، هتفضل القيم الديفولت
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> splashColors = [
      Colors.red[300]!,
      Colors.orange[300]!,
      Colors.green[300]!,
      Colors.blue[700]!,
      Colors.blue[300]!,
      Colors.purple[400]!,
      Colors.purple[700]!,
      Colors.blue[500]!,
      Colors.grey[400]!,
      Colors.pink[300]!,
      Colors.green[400]!,
      Colors.amber[300]!,
      Colors.blue[400]!,
      Colors.blue[600]!,
      Colors.blue[800]!,
      const Color(0xFF66BB6A),
    ];

    final List<Color> iconColors = [
      Colors.red[600]!,
      Colors.orange[600]!,
      Colors.green[600]!,
      Colors.blue[900]!,
      Colors.blue[500]!,
      Colors.purple[600]!,
      Colors.purple[900]!,
      Colors.blue[700]!,
      Colors.grey[600]!,
      Colors.pink[500]!,
      Colors.green[600]!,
      Colors.amber[600]!,
      Colors.blue[600]!,
      Colors.blue[800]!,
      Colors.blue[900]!,
      const Color(0xFF4CAF50),
    ];

    return BlocProvider(
      create: (context) => SignoutCubit(getIt<AuthRepo>()),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocConsumer<SignoutCubit, SignoutState>(
          listener: (context, state) {
            if (state is SignoutSuccess) {
              BuildSnackBar(context, 'تم تسجيل الخروج');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            }
            if (state is SignoutFailed) {
              BuildSnackBar(context, state.errMessage);
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 16),
                          CircleAvatar(
                            radius: MediaQuery.sizeOf(context).width * 0.10,
                            backgroundImage: NetworkImage(userImageUrl),
                            onBackgroundImageError: (_, __) =>
                                const Icon(Icons.person, size: 40),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                userRole,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  OutlinedButton(
                                    onPressed: () {
                                      // Navigate to edit profile page
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: Colors.blue[500]!,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      "Edit profile",
                                      style: TextStyle(color: Colors.blue[500]),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  OutlinedButton(
                                    onPressed: () async {
                                      context.read<SignoutCubit>().signOut();
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.red[500]!),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      "Log Out",
                                      style: TextStyle(color: Colors.red[500]),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.grey, thickness: 1),
                      const SizedBox(height: 16),
                      // Account Management
                      const Text(
                        "Account Management",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildProfileItem(
                        context,
                        "Change email",
                        Icons.email,
                        Colors.white,
                        iconColors[0],
                        '/change-email',
                      ),
                      _buildProfileItem(
                        context,
                        "Change password",
                        Icons.lock,
                        Colors.white,
                        iconColors[1],
                        '/forget-password',
                      ), // ForgetPasswordPage
                      _buildProfileItem(
                        context,
                        "Last login timestamp",
                        Icons.access_time,
                        Colors.white,
                        iconColors[2],
                        '/last-login',
                      ), // LastLoginPage
                      const SizedBox(height: 16),
                      const Divider(color: Colors.grey, thickness: 1),
                      const SizedBox(height: 16),
                      // User Management
                      const Text(
                        "User Management",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildProfileItem(
                        context,
                        "View all users",
                        Icons.group,
                        Colors.white,
                        iconColors[3],
                        '/family-members',
                      ), // FamilyMembersPage
                      _buildProfileItem(
                        context,
                        "Add new user",
                        Icons.person_add,
                        Colors.white,
                        iconColors[4],
                        '/manage-requests',
                      ), // ManageRequestsPage
                      _buildProfileItem(
                        context,
                        "Disable user",
                        Icons.person_off,
                        Colors.white,
                        iconColors[5],
                        '/manage-requests',
                      ), // ManageRequestsPage
                      _buildProfileItem(
                        context,
                        "Modify roles",
                        Icons.admin_panel_settings,
                        Colors.white,
                        iconColors[6],
                        '/modify-roles',
                      ),
                      _buildProfileItem(
                        context,
                        "View user activity logs",
                        Icons.history,
                        Colors.white,
                        iconColors[7],
                        '/view-logs',
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.grey, thickness: 1),
                      const SizedBox(height: 16),
                      // Device Control & Monitoring
                      const Text(
                        "Device Control & Monitoring",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildProfileItem(
                        context,
                        "View connected devices",
                        Icons.devices,
                        Colors.white,
                        iconColors[5],
                        '/devices',
                      ), // DevicesPage
                      _buildProfileItem(
                        context,
                        "Add/Remove device",
                        Icons.add_circle_outline,
                        Colors.white,
                        iconColors[6],
                        '/scan-devices',
                      ), // ScanDevicesPage
                      _buildProfileItem(
                        context,
                        "Update/Restart device",
                        Icons.update,
                        Colors.white,
                        iconColors[7],
                        '/update-restart-device',
                      ),
                      _buildProfileItem(
                        context,
                        "Device usage report",
                        Icons.bar_chart,
                        Colors.white,
                        iconColors[8],
                        '/energy',
                      ), // EnergyPage
                      _buildProfileItem(
                        context,
                        "Device failure alert",
                        Icons.error,
                        Colors.white,
                        iconColors[9],
                        '/device-failure',
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.grey, thickness: 1),
                      const SizedBox(height: 16),
                      // Security & Access Control
                      const Text(
                        "Security & Access Control",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildProfileItem(
                        context,
                        "Enable security features",
                        Icons.security,
                        Colors.white,
                        iconColors[10],
                        '/enable-security',
                      ),
                      _buildProfileItem(
                        context,
                        "Live camera feed & Recorded videos",
                        Icons.videocam,
                        Colors.white,
                        iconColors[11],
                        '/camera-view',
                      ), // CameraViewPage
                      _buildProfileItem(
                        context,
                        "Smart locks & Access control",
                        Icons.lock_open,
                        Colors.white,
                        iconColors[12],
                        '/smart-locks',
                      ),
                      _buildProfileItem(
                        context,
                        "Manage security alerts",
                        Icons.alarm,
                        Colors.white,
                        iconColors[13],
                        '/manage-alerts',
                      ),
                      _buildProfileItem(
                        context,
                        "Manage user access permissions",
                        Icons.supervisor_account,
                        Colors.white,
                        iconColors[14],
                        '/manage-requests',
                      ), // ManageRequestsPage
                      const SizedBox(height: 16),
                      const Divider(color: Colors.grey, thickness: 1),
                      const SizedBox(height: 16),
                      // Energy Management
                      const Text(
                        "Energy Management",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildProfileItem(
                        context,
                        "Energy consumption reports",
                        Icons.bolt,
                        Colors.white,
                        iconColors[15],
                        '/energy',
                      ), // EnergyPage
                      _buildProfileItem(
                        context,
                        "Eco mode & Energy saving",
                        Icons.eco,
                        Colors.white,
                        iconColors[0],
                        '/energy-saving',
                      ), // EnergySavingPage
                      const SizedBox(height: 16),
                      const Divider(color: Colors.grey, thickness: 1),
                      const SizedBox(height: 16),
                      // Automation
                      const Text(
                        "Automation",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildProfileItem(
                        context,
                        "Set Automation schedules",
                        Icons.schedule,
                        Colors.white,
                        iconColors[8],
                        '/automation',
                      ), // AutomationPage
                      _buildProfileItem(
                        context,
                        "Smart device automation",
                        Icons.smart_toy,
                        Colors.white,
                        iconColors[9],
                        '/scan-devices',
                      ), // ScanDevicesPage
                      const SizedBox(height: 16),
                      const Divider(color: Colors.grey, thickness: 1),
                      const SizedBox(height: 16),
                      // Notification & Alerts
                      const Text(
                        "Notification & Alerts",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildProfileItem(
                        context,
                        "View recent notifications",
                        Icons.notifications,
                        Colors.white,
                        iconColors[10],
                        '/notifications',
                      ), // NotificationsPage
                      _buildProfileItem(
                        context,
                        "Security & Emergency alerts",
                        Icons.warning,
                        Colors.white,
                        iconColors[11],
                        '/security-alerts',
                      ),
                      _buildProfileItem(
                        context,
                        "Scheduled reminders",
                        Icons.event,
                        Colors.white,
                        iconColors[12],
                        '/scheduled-reminders',
                      ),
                      _buildProfileItem(
                        context,
                        "Customize notification settings",
                        Icons.settings,
                        Colors.white,
                        iconColors[13],
                        '/customize-notifications',
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.grey, thickness: 1),
                      const SizedBox(height: 16),
                      // System & Network
                      const Text(
                        "System & Network",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildProfileItem(
                        context,
                        "Reset system",
                        Icons.refresh,
                        Colors.white,
                        iconColors[14],
                        '/reset-system',
                      ),
                      _buildProfileItem(
                        context,
                        "Export & Backup data",
                        Icons.cloud_download,
                        Colors.white,
                        iconColors[15],
                        '/export-backup',
                      ),
                      _buildProfileItem(
                        context,
                        "WiFi & Network configuration",
                        Icons.wifi,
                        Colors.white,
                        iconColors[0],
                        '/wifi-config',
                      ),
                      _buildProfileItem(
                        context,
                        "System & Software updates",
                        Icons.system_update,
                        Colors.white,
                        iconColors[1],
                        '/system-updates',
                      ),
                      _buildProfileItem(
                        context,
                        "Privacy & Data management",
                        Icons.privacy_tip,
                        Colors.white,
                        iconColors[2],
                        '/privacy-data',
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.grey, thickness: 1),
                      const SizedBox(height: 16),
                      // More Info & Support
                      const Text(
                        "More Info & Support",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildProfileItem(
                        context,
                        "Help",
                        Icons.help,
                        Colors.white,
                        iconColors[3],
                        '/help',
                      ),
                      _buildProfileItem(
                        context,
                        "About",
                        Icons.info,
                        Colors.white,
                        iconColors[4],
                        '/about',
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileItem(
    BuildContext context,
    String title,
    IconData icon,
    Color backgroundColor,
    Color iconColor,
    String route,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
