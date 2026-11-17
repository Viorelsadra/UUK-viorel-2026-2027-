import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_color.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.pushReplacementNamed(context, '/beranda');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColor.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColor.textTertiary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.science_rounded,
                  size: 72,
                  color: AppColor.primary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Inventaris Alat Lab',
                style: TextStyle(
                  color: AppColor.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sistem Manajemen Peralatan Laboratorium',
                style: TextStyle(
                  color: AppColor.textPrimary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(
                color: AppColor.textPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}