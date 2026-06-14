import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        title: const Text('Comment ça marche', style: TextStyle(color: Colors.white)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoCard(Icons.photo_camera_rounded, '1. Prends une photo', 'Photographie les déchets que tu souhaites partager (plastique, métal, carton, etc.)', AppColors.green),
            const SizedBox(height: 12),
            _infoCard(Icons.description_rounded, '2. Décris', 'Ajoute une description et sélectionne les types de déchets pour mieux les identifier', AppColors.yellow),
            const SizedBox(height: 12),
            _infoCard(Icons.publish_rounded, '3. Publie', 'Partage ta publication avec la communauté RecycPay', AppColors.blue),
            const SizedBox(height: 12),
            _infoCard(Icons.recycling_rounded, '4. Reçois des points', 'Gagne des points éco à chaque publication et contribue à un Cameroun plus propre', AppColors.green),
            const SizedBox(height: 12),
            _infoCard(Icons.map_rounded, '5. Suis la carte', 'Utilise la carte pour voir les collecteurs et trieurs actifs près de chez toi', AppColors.orange),
            const SizedBox(height: 12),
            _infoCard(Icons.wallet_rounded, '6. Gagne de l\'argent', 'Les points éco sont convertis en crédits dans ton portefeuille. Retire via Mobile Money !', AppColors.green),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String desc, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: AppColors.grey, fontSize: 13, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
