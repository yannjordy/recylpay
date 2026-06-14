import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    if (auth.isLoggedIn && auth.user != null) {
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('landing_seen') ?? false;
    if (mounted) {
      Navigator.pushReplacementNamed(context, seen ? '/login' : '/landing');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset('assets/images/logo.png', width: 100, height: 100, fit: BoxFit.cover),
            ),
            const SizedBox(height: 24),
            Text('RecycPay', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Valorisons nos déchets ensemble', style: TextStyle(color: AppColors.grey)),
          ],
        ),
      ),
    );
  }
}
