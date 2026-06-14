import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        title: const Text('Confidentialité', style: TextStyle(color: Colors.white)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Protection de vos données', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text(
              'RecycPay respecte votre vie privée. Les données collectées sont utilisées uniquement dans le cadre du service de gestion des déchets et du recyclage au Cameroun.',
              style: TextStyle(color: AppColors.grey, fontSize: 14, height: 1.5),
            ),
            SizedBox(height: 20),
            Text('Données collectées', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('• Nom et informations de profil\n• Localisation pour le service de collecte\n• Types de déchets partagés\n• Photos et publications', style: TextStyle(color: AppColors.grey, fontSize: 14, height: 1.5)),
            SizedBox(height: 20),
            Text('Sécurité', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('Toutes les données sont chiffrées et stockées en toute sécurité. Nous ne partageons jamais vos informations personnelles sans votre consentement.', style: TextStyle(color: AppColors.grey, fontSize: 14, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
