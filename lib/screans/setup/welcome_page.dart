import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF5857AA), Color(0xFF232344)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.4, 0.9],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.home, size: 80, color: Colors.white),
              const Text(
                'Welcome To   \nApp!',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              const Text(
                'Enhance Your Living Today.',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 120),
              ElevatedButton(
                onPressed: () {
                  // Navigate to /signup/admin using Named Route
                  Navigator.pushNamed(context, '/signup/admin');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4FC3F7),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text(
                  'Sign Up As Admin',
                  style: TextStyle(color: Color(0xFF28284E), fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Navigate to /signup/member using Named Route
                  Navigator.pushNamed(context, '/signup/member');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  side: const BorderSide(color: Color(0xFF4FC3F7), width: 3),
                ),
                child: const Text(
                  'Sign Up As Member',
                  style: TextStyle(color: Color(0xFF4FC3F7)),
                ),
              ),
              const SizedBox(height: 20),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    TextSpan(
                      text: 'Login',
                      style: const TextStyle(
                        color: Color(0xFF4FC3F7),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFF4FC3F7),
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushNamed(context, '/login');
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}