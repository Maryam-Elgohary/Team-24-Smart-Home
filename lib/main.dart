import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:updated_smart_home/core/bloc_observer.dart';
import 'package:updated_smart_home/core/helps%20functions/getUserData.dart';
import 'package:updated_smart_home/core/services/get_it.dart';
import 'package:updated_smart_home/core/services/sharedPreference_singleton.dart';
import 'package:updated_smart_home/core/utils/backend_endpoints.dart';
import 'package:updated_smart_home/firebase_options.dart';
import 'package:updated_smart_home/models/LightsControlPage.dart';
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
import 'package:updated_smart_home/screans/auth/updated/auth/domain/entities/user_entity.dart';
import 'package:updated_smart_home/screans/automation/automation.dart';
import 'package:updated_smart_home/screans/home/EnergySaving.dart';
import 'package:updated_smart_home/screans/home/ThermostatPage.dart';
import 'package:updated_smart_home/screans/home/cameras_screen.dart';
import 'package:updated_smart_home/screans/home/devices_screen.dart';
import 'package:updated_smart_home/screans/home/energy_screen.dart';
import 'package:updated_smart_home/screans/home/familymember.dart';
import 'package:updated_smart_home/screans/home/home.dart';
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
import 'package:updated_smart_home/screans/rooms/scandevice.dart';
import 'package:updated_smart_home/screans/rooms/washingroom.dart';
import 'package:updated_smart_home/screans/setup/address.dart';
import 'package:updated_smart_home/screans/setup/address_manually.dart';
import 'package:updated_smart_home/screans/setup/managerequest.dart';
import 'package:updated_smart_home/screans/setup/upload_contract.dart';
import 'package:updated_smart_home/screans/setup/waiting.dart';
import 'package:updated_smart_home/screans/setup/welcome_page.dart';
import 'package:updated_smart_home/screans/test/test.dart';
import 'package:updated_smart_home/screans/test/testapi.dart';
import 'package:updated_smart_home/services/api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  setup();
  await SharPref.init();
  Bloc.observer = StateObserver();
  // to be able to use hive with flutter code
  await Hive.initFlutter();
  Hive.registerAdapter(UserEntityAdapter());

  // get a space for a specific type of data in memory
  await Hive.openBox<UserEntity>(BackendEndpoints.hiveBoxName);
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(SmartHomeApp(initialRoute: isLoggedIn ? '/login' : '/select-role'));
}

class SmartHomeApp extends StatelessWidget {
  final String initialRoute;

  const SmartHomeApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartHome App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        cardTheme: const CardThemeData(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.grey),
          bodySmall: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        iconTheme: const IconThemeData(size: 40, color: Colors.grey),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.all(Colors.white),
          trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? Colors.blue
                : Colors.grey,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            textStyle: const TextStyle(fontSize: 16),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.blue),
        ),
      ),
      initialRoute:
          initialRoute, // غيرنا الـ initialRoute لصفحة MainPage الجديدة
      routes: {
        '/main': (context) =>
            const MainPage(), // صفحة جديدة تحتوي على Bottom Navigation Bar
        '/testapi': (context) => const ApiTestScreen(),
        '/test': (context) => const TestScreen(),
        '/thermostat': (context) => ThermostatPage(),
        '/select-role': (context) => const SelectRolePage(),

        '/welcome': (context) => const WelcomePage(),
        '/login': (context) => LoginPage(),
        '/signup/member': (context) => const SignUpPage(),
        '/signup/admin': (context) => const SignUpPage(),
        '/home': (context) => const HomePage(),
        '/voice-page': (context) => VoicePage(),
        '/energy-monitoring': (context) => EnergyPage(),
        '/devices': (context) => DevicesPage(),
        '/notifications': (context) => Notificationpage(adminID: getUser().uid),
        '/cameras': (context) => CameraPage(),
        '/profile': (context) => ProfilePage(),
        '/last-login': (context) => LastLoginPage(),
        '/face-id': (context) => FaceId(),
        '/address': (context) => const LocationPage(),
        '/enter-address': (context) => const EnterAddressPage(),
        '/upload-contract': (context) => UploadContractPage(),
        '/waiting-approval': (context) => WaitingApprovalPage(),
        '/two-factor': (context) => TwoFactorPage(),
        '/otp-verification': (context) => OtpVerificationPage(),
        '/forget-password': (context) => ForgetPasswordPage(),
        '/reset-password': (context) => ResetPasswordPage(token: ''),
        '/password-reset-success': (context) => PasswordResetSuccessPage(),
        '/master-bedroom': (context) => const MasterRoomPage(),
        '/child-bedroom': (context) => const ChildrenRoomPage(),
        '/living-room': (context) => const LivingRoomPage(),
        '/kitchen': (context) => const KitchenPage(),
        '/washing-room': (context) => const WashingRoomPage(),
        '/bathroom': (context) => const BathroomPage(),
        '/office': (context) => const OfficePage(),
        '/lights-control': (context) => const LightsControlPage(),
        '/guest-room': (context) => const GuestRoomPage(),
        '/automation': (context) =>
            const AutomationPage(), // إضافة AutomationPage
        '/family-members': (context) => UsersManagementPage(),
        '/manage-requests': (context) => ManageRequestsPage(),
        '/scan-devices': (context) => ScanDevicesPage(roomId: ''),
        '/energy': (context) => EnergyPage(),
        '/camera-view': (context) => CameraViewPage(location: ''),
        '/energy-saving': (context) => EnergySavingPage(),
      },
      onGenerateRoute: (settings) {
        final protectedRoutes = [
          '/main', // أضفنا الـ MainPage للـ Protected Routes
          '/home',
          '/voice-page',
          '/energy-monitoring',
          '/devices',
          '/cameras',
          '/profile',
          '/last-login',
          '/upload-contract',
          '/waiting-approval',
          '/two-factor',
          '/otp-verification',
          '/forget-password',
          '/reset-password',
          '/password-reset-success',
          '/master-bedroom',
          '/child-bedroom',
          '/living-room',
          '/kitchen',
          '/washing-room',
          '/bathroom',
          '/office',
          '/lights-control',
          '/guest-room',
          '/automation', // أضفنا AutomationPage للـ Protected Routes
        ];

        final apiService = ApiService();
        if (protectedRoutes.contains(settings.name) &&
            apiService.token == null) {
          return MaterialPageRoute(
            builder: (context) => LoginPage(),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}

// صفحة جديدة تحتوي على Bottom Navigation Bar
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    DevicesPage(),
    CameraPage(),
    const AutomationPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // عرض الصفحة المختارة
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.devices), label: 'Devices'),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Cameras',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Automation',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // للتأكد إن كل العناصر تظهر
      ),
    );
  }
}
