import 'package:flutter/material.dart';
import 'package:updated_smart_home/screans/auth/sign_up_screen.dart';
import 'package:updated_smart_home/screans/auth/user_signup.dart';

class SelectRolePage extends StatefulWidget {
  const SelectRolePage({super.key});

  @override
  _SelectRolePageState createState() => _SelectRolePageState();
}

class _SelectRolePageState extends State<SelectRolePage> {
  String? _selectedRole;
  DateTime? _guestExpirationDate;
  bool _isAccessDenied = false;

  // تحديد مستويات الوصول لكل دور
  Map<String, String> _accessLevels = {
    'Admin': 'Full control over devices and users.',
    'Family Member': 'Access shared devices and limited access.',
  };

  // التحقق من تاريخ الانتهاء للضيف
  void _checkGuestAccess() {
    if (_selectedRole == 'Guest' && _guestExpirationDate != null) {
      final now = DateTime.now();
      if (now.isAfter(_guestExpirationDate!)) {
        setState(() {
          _isAccessDenied = true;
        });
      } else {
        setState(() {
          _isAccessDenied = false;
        });
      }
    }
  }

  Future<void> _selectExpirationDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _guestExpirationDate) {
      setState(() {
        _guestExpirationDate = picked;
      });
      _checkGuestAccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Select Your Role',
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                children: [
                  FloatingRoleImage(),
                  SizedBox(height: 30),
                  _buildRoleCard('Admin', _accessLevels['Admin']!),
                  SizedBox(height: 20),
                  _buildRoleCard(
                    'Family Member',
                    _accessLevels['Family Member']!,
                  ),

                  if (_selectedRole == null)
                    const Text(
                      '*Please select a role to continue.',
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  if (_selectedRole == 'Guest' && _guestExpirationDate == null)
                    const Text(
                      '*Please enter a valid expiration date to continue.',
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  if (_isAccessDenied)
                    const Text(
                      '*Access denied: Guest expiration date has passed.',
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                ],
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  if (_selectedRole == "Admin") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpPage(),
                      ),
                    );
                  }
                  if (_selectedRole == "Family Member") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserLoginPage(),
                      ),
                    );
                  }
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5857AA),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(String title, String subtitle, {bool isGuest = false}) {
    return Card(
      elevation: _selectedRole == title ? 20 : 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: _selectedRole == title ? const Color(0xFF5857AA) : Colors.grey,
          width: _selectedRole == title ? 3 : 1,
        ),
      ),
      child: ListTile(
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            if (isGuest && _selectedRole == 'Guest') ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Expiration date: '),
                  TextButton(
                    onPressed: _selectExpirationDate,
                    child: Text(
                      _guestExpirationDate == null
                          ? 'Select date'
                          : '${_guestExpirationDate!.day}-${_guestExpirationDate!.month}-${_guestExpirationDate!.year}',
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Radio<String>(
          value: title,
          groupValue: _selectedRole,
          onChanged: (value) {
            setState(() {
              _selectedRole = value;
              if (!isGuest) {
                _guestExpirationDate = null;
                _isAccessDenied = false;
              }
            });
          },
        ),
        onTap: () {
          setState(() {
            _selectedRole = title;
            if (!isGuest) {
              _guestExpirationDate = null;
              _isAccessDenied = false;
            }
          });
        },
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}

class FloatingRoleImage extends StatefulWidget {
  @override
  _FloatingRoleImageState createState() => _FloatingRoleImageState();
}

class _FloatingRoleImageState extends State<FloatingRoleImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4), // حركة بطيئة ومريحة
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0,
      end: 15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
      child: SizedBox(
        height: 250, // تقدير مناسب لحجم الصورة 4*6
        child: Image.asset(
          "assets/images/select-role.jpg",
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
