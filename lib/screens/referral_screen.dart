import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        title: const Text('Mon Parrainage', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: isDesktop ? 600 : double.infinity,
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Code card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.green.withValues(alpha: 0.15), AppColors.dark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.card_giftcard_rounded, color: AppColors.green, size: 36),
                        ),
                        const SizedBox(height: 16),
                        const Text('Ton code de parrainage',
                            style: TextStyle(color: AppColors.grey, fontSize: 14)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            if (user?.referralCode != null) {
                              Clipboard.setData(ClipboardData(text: user!.referralCode!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Code copié !'),
                                  backgroundColor: AppColors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.dark,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.green, width: 2),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  user?.referralCode ?? '------',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 4,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.copy_rounded, color: AppColors.green, size: 22),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('Tapez pour copier', style: TextStyle(color: AppColors.grey, fontSize: 11)),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final link = auth.referralLink;
                              if (link.isNotEmpty) {
                                Clipboard.setData(ClipboardData(text: link));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Lien de parrainage copié ! Partage-le avec tes proches.'),
                                    backgroundColor: AppColors.green,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.share_rounded, size: 20),
                            label: const Text('Copier le lien de parrainage'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats
                  Text('Mes statistiques', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _statBox('Amis parrainés', '${auth.referralCount}', Icons.people_rounded, AppColors.blue)),
                      const SizedBox(width: 12),
                      Expanded(child: _statBox('Gains', '${auth.referralCount * 500} FCFA', Icons.monetization_on_rounded, AppColors.green)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.softBlack,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info_rounded, color: AppColors.yellow, size: 20),
                            SizedBox(width: 8),
                            Text('Comment ça marche ?',
                                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _infoRow('1.', 'Partage ton code ou ton lien avec tes amis'),
                        _infoRow('2.', 'Ils s\'inscrivent en utilisant ton code'),
                        _infoRow('3.', 'Tu gagnes 500 FCFA par ami inscrit'),
                        _infoRow('4.', 'Le montant est crédité directement sur ton portefeuille'),
                      ],
                    ),
                  ),

                  if (auth.referredUsers.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Amis parrainés', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    ...auth.referredUsers.map((email) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.softBlack,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.person_add_rounded, color: AppColors.green, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(email, style: const TextStyle(color: Colors.white, fontSize: 14)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('+500 FCFA', style: TextStyle(color: AppColors.green, fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    )),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.softBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _infoRow(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(num, style: const TextStyle(color: AppColors.green, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: AppColors.grey, fontSize: 14))),
        ],
      ),
    );
  }
}
