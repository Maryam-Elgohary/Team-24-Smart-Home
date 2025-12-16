import 'package:flutter/material.dart';
import 'package:updated_smart_home/core/helps%20functions/getUserData.dart';
import 'package:updated_smart_home/screans/auth/2fa.dart';
import 'package:updated_smart_home/screans/auth/OTPScreen.dart';
import 'package:updated_smart_home/screans/auth/face_id.dart';
import 'package:updated_smart_home/screans/auth/forgetpass.dart';
import 'package:updated_smart_home/screans/auth/last_login_screen.dart';
import 'package:updated_smart_home/screans/auth/login_screen.dart';
import 'package:updated_smart_home/screans/auth/password_reset_success_page.dart';
import 'package:updated_smart_home/screans/auth/reset_password_page.dart';
import 'package:updated_smart_home/screans/auth/selectrole.dart';
import 'package:updated_smart_home/screans/auth/sign_up_screen.dart';
import 'package:updated_smart_home/screans/automation/automation.dart';
import 'package:updated_smart_home/screans/home/EnergySaving.dart';
import 'package:updated_smart_home/screans/home/ThermostatPage.dart';
import 'package:updated_smart_home/screans/home/cameras_screen.dart';
import 'package:updated_smart_home/screans/home/devices_screen.dart';
import 'package:updated_smart_home/screans/home/energy_screen.dart';
import 'package:updated_smart_home/screans/home/familymember.dart';
import 'package:updated_smart_home/screans/home/home.dart';
import 'package:updated_smart_home/screans/home/light_control.dart';
import 'package:updated_smart_home/screans/home/notificationpage.dart';
import 'package:updated_smart_home/screans/home/profile_screen.dart';
import 'package:updated_smart_home/screans/home/voice_control_screen.dart';
import 'package:updated_smart_home/screans/rooms/LivingRoomPage.dart';
import 'package:updated_smart_home/screans/rooms/bathroom.dart';
import 'package:updated_smart_home/screans/rooms/childrenroom.dart';
import 'package:updated_smart_home/screans/rooms/guest.dart';
import 'package:updated_smart_home/screans/rooms/kitchen.dart';
import 'package:updated_smart_home/screans/rooms/master.dart';
import 'package:updated_smart_home/screans/rooms/office.dart';
import 'package:updated_smart_home/screans/rooms/washingroom.dart';
import 'package:updated_smart_home/screans/setup/address.dart';
import 'package:updated_smart_home/screans/setup/address_manually.dart';
import 'package:updated_smart_home/screans/setup/managerequest.dart';
import 'package:updated_smart_home/screans/setup/upload_contract.dart';
import 'package:updated_smart_home/screans/setup/waiting.dart';
import 'package:updated_smart_home/screans/setup/welcome_page.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test All Screens'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Setup Screens',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          _buildTestButton(
            context,
            'Welcome Page',
            '/welcome',
            'Start the app journey',
            widget: const WelcomePage(),
          ),
          _buildTestButton(
            context,
            'Location Page',
            '/address',
            'Enter your location',
            widget: const LocationPage(),
          ),
          _buildTestButton(
            context,
            'Enter Address Manually',
            '/enter-address',
            'Manually enter address',
            widget: const EnterAddressPage(),
          ),
          _buildTestButton(
            context,
            'Upload Contract',
            '/upload-contract',
            'Upload contract for approval',
            widget: UploadContractPage(),
          ),
          _buildTestButton(
            context,
            'Waiting Approval',
            '/waiting-approval',
            'Waiting for admin approval',
            widget: WaitingApprovalPage(),
          ),
          _buildTestButton(
            context,
            'Face ID',
            '/face-id',
            'Set up Face ID',
            widget: const FaceId(),
          ),
          _buildTestButton(
            context,
            'Energy Saving',
            '/energy-saving',
            'View energy saving options',
            widget: const EnergySavingPage(),
          ),
          _buildTestButton(
            context,
            'select-role',
            '/select-role',
            'View energy saving options',
            widget: const SelectRolePage(),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Auth Screens',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          _buildTestButton(
            context,
            'Login',
            '/login',
            'Login to your account',
            widget: LoginPage(),
          ),
          _buildTestButton(
            context,
            'Sign Up (Member)',
            '/signup/member',
            'Sign up as a member',
            widget: const SignUpPage(),
          ),
          _buildTestButton(
            context,
            'Sign Up (Admin)',
            '/signup/admin',
            'Sign up as an admin',
            widget: const SignUpPage(),
          ),
          _buildTestButton(
            context,
            'Forget Password',
            '/forget-password',
            'Reset password via SMS or email',
            widget: ForgetPasswordPage(),
          ),
          _buildTestButton(
            context,
            'Reset Password',
            '/reset-password',
            'Set a new password',
            widget: ResetPasswordPage(token: ''),
          ),
          _buildTestButton(
            context,
            'Password Reset Success',
            '/password-reset-success',
            'Password reset confirmation',
            widget: PasswordResetSuccessPage(),
          ),
          _buildTestButton(
            context,
            'Two-Factor Auth',
            '/two-factor',
            'Enable 2FA',
            widget: TwoFactorPage(),
          ),
          _buildTestButton(
            context,
            'OTP Verification',
            '/otp-verification',
            'Verify OTP',
            widget: OtpVerificationPage(),
          ),
          _buildTestButton(
            context,
            'Manage Requests',
            '/manage-request',
            'Manage join requests',
            widget: ManageRequestsPage(),
          ),
          _buildTestButton(
            context,
            'Thermostat',
            '/thermo',
            'Control thermostat',
            widget: ThermostatPage(),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Home Screen',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          _buildTestButton(
            context,
            'Home Page',
            '/home',
            'View all rooms and summary',
            widget: const HomePage(),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Room Screens',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          _buildTestButton(
            context,
            'Living Room',
            '/living-room',
            'Control your living room',
            widget: const LivingRoomPage(),
          ),
          _buildTestButton(
            context,
            'Master Bedroom',
            '/master-bedroom',
            'Control your master bedroom',
            widget: const MasterRoomPage(),
          ),
          _buildTestButton(
            context,
            'Child Bedroom',
            '/child-bedroom',
            'Control your child bedroom',
            widget: const ChildrenRoomPage(),
          ),
          _buildTestButton(
            context,
            'Guest Room',
            '/guest-room',
            'Control your guest room',
            widget: const GuestRoomPage(),
          ),
          _buildTestButton(
            context,
            'Kitchen',
            '/kitchen',
            'Control your kitchen',
            widget: const KitchenPage(),
          ),
          _buildTestButton(
            context,
            'Washing Room',
            '/washing-room',
            'Control your washing room',
            widget: const WashingRoomPage(),
          ),
          _buildTestButton(
            context,
            'Bathroom',
            '/bathroom',
            'Control your bathroom',
            widget: const BathroomPage(),
          ),
          _buildTestButton(
            context,
            'Office',
            '/office',
            'Control your office',
            widget: const OfficePage(),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Main Screens',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          _buildTestButton(
            context,
            'Energy Monitoring',
            '/energy-monitoring',
            'Monitor energy usage',
            widget: EnergyPage(),
          ),
          _buildTestButton(
            context,
            'Devices',
            '/devices',
            'Manage devices',
            widget: DevicesPage(),
          ),
          _buildTestButton(
            context,
            'Cameras',
            '/cameras',
            'View cameras',
            widget: CameraPage(),
          ),
          _buildTestButton(
            context,
            'Profile',
            '/profile',
            'View user profile',
            widget: ProfilePage(),
          ),
          _buildTestButton(
            context,
            'Notifications',
            '/notifications',
            'View notifications',
            widget: Notificationpage(adminID: getUser().uid),
          ),
          _buildTestButton(
            context,
            'Voice Control',
            '/voice-page',
            'Control devices with voice',
            widget: VoicePage(),
          ),
          _buildTestButton(
            context,
            'Last Login',
            '/last-login',
            'View last login details',
            widget: LastLoginPage(),
          ),
          _buildTestButton(
            context,
            'Lights Control',
            '/lights-control',
            'Control lights for all rooms',
            widget: const LightsControlPage(),
          ),
          _buildTestButton(
            context,
            'Family Members',
            '/family',
            'Manage family members',
            widget: const UsersManagementPage(),
          ),
          _buildTestButton(
            context,
            'Automation',
            '/automation',
            'Schedule automation settings',
            widget: const AutomationPage(),
          ), // إضافة AutomationPage
        ],
      ),
    );
  }

  Widget _buildTestButton(
    BuildContext context,
    String text,
    String route,
    String description, {
    Widget? widget,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Card(
        elevation: 2,
        child: ListTile(
          title: Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            description,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          trailing: const Icon(Icons.arrow_forward, color: Colors.blue),
          onTap: () {
            if (widget != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => widget),
              );
            } else {
              Navigator.pushNamed(context, route);
            }
          },
        ),
      ),
    );
  }
}
