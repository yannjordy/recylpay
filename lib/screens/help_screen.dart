import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        title: const Text('Aide & Support', style: TextStyle(color: Colors.white)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Comment utiliser RecycPay', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            _HelpItem('Comment publier ?', 'Va dans l\'onglet "Publier", décris tes déchets, sélectionne les types et publie.'),
            _HelpItem('Comment gagner des points ?', 'Chaque publication te rapporte des points éco. Plus tu publies, plus tu gagnes.'),
            _HelpItem('Comment retirer de l\'argent ?', 'Va dans la page Wallet, clique sur "Retrait" et entre ton numéro Mobile Money.'),
            _HelpItem('Comment voir la carte ?', 'L\'onglet "Carte" affiche les collecteurs, trieurs et livreurs actifs près de chez toi.'),
            _HelpItem('Comment contacter le support ?', 'Envoie un message via l\'onglet "Messages" ou écris à support@recylpay.com'),
            SizedBox(height: 24),
            Text('Contact', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('Email: support@recylpay.com\nTél: +237 670 000 000', style: TextStyle(color: AppColors.grey, fontSize: 14, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final String title;
  final String content;
  const _HelpItem(this.title, this.content);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.green, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(color: AppColors.grey, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}
