import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        title: const Text('Mon Profil', style: TextStyle(color: Colors.white)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: DesktopScaffold(child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.green.withValues(alpha: 0.15),
                border: Border.all(color: AppColors.green, width: 3),
                image: user?.photoUrl != null
                    ? DecorationImage(image: NetworkImage(user!.photoUrl!), fit: BoxFit.cover)
                    : null,
              ),
              child: user?.photoUrl == null
                  ? const Icon(Icons.person_rounded, color: AppColors.green, size: 48)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(user?.name ?? 'Utilisateur', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(user?.uniqueId ?? '', style: const TextStyle(color: AppColors.grey, fontSize: 14)),
            const SizedBox(height: 24),
            _infoTile(Icons.badge_rounded, 'Rôle', user?.role ?? ''),
            _infoTile(Icons.star_rounded, 'Note', '${user?.rating ?? 0}/5'),
            _infoTile(Icons.check_circle_rounded, 'Missions complétées', '${user?.completedMissions ?? 0}'),
            if (user?.collectedTypes != null && user!.collectedTypes!.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Align(alignment: Alignment.centerLeft, child: Text('Types collectés', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: user.collectedTypes!.map((t) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(t, style: const TextStyle(color: AppColors.green, fontSize: 13)),
                )).toList(),
              ),
            ],
          ],
        ),
      )),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.green, size: 22),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 14)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
