import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        title: const Text('À propos', style: TextStyle(color: Colors.white)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: DesktopScaffold(child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset('assets/images/logo.png', width: 64, height: 64, fit: BoxFit.cover),
              ),
              const SizedBox(height: 16),
              const Text('RecycPay', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Version 1.0.0', style: TextStyle(color: AppColors.grey, fontSize: 14)),
              const SizedBox(height: 24),
              const Text(
                'RecycPay est une application de gestion des déchets et de recyclage au Cameroun. Notre mission est de faciliter la collecte, le tri et le recyclage des déchets tout en créant une communauté éco-responsable.',
                style: TextStyle(color: AppColors.grey, fontSize: 14, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const Text('© 2026 RecycPay. Tous droits réservés.', style: TextStyle(color: AppColors.grey, fontSize: 12)),
            ],
          ),
        ),
      )),
    );
  }
}
