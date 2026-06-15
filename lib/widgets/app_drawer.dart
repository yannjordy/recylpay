import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Drawer(
      backgroundColor: AppColors.dark,
      width: 280,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, user, auth),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _drawerItem(Icons.person_rounded, 'Mon Profil', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/profile');
                  }),
                  _drawerItem(Icons.photo_library_rounded, 'Mes Publications', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/my-posts');
                  }),
                  _drawerItem(Icons.delete_sweep_rounded, 'Collecte', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/collection');
                  }),
                  _drawerItem(Icons.flag_rounded, 'Missions', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/missions');
                  }),
                  _drawerItem(Icons.settings_rounded, 'Paramètres', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/settings');
                  }),
                  _drawerItem(Icons.eco_rounded, 'Impact Écologique', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/eco-impact');
                  }),
                  _drawerItem(Icons.card_giftcard_rounded, 'Parrainage', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/referral');
                  }),
                  _drawerItem(Icons.message_rounded, 'Messages', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/messages');
                  }),
                  _drawerItem(Icons.notifications_rounded, 'Notifications', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/notifications');
                  }),
                  const Divider(color: AppColors.glassBorder, height: 1),
                  const Divider(color: AppColors.glassBorder, height: 1),
                  _drawerItem(Icons.recycling_rounded, 'Comment ça marche', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/how-it-works');
                  }),
                  _drawerItem(Icons.leaderboard_rounded, 'Classement', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/ranking');
                  }),
                  _drawerItem(Icons.shield_rounded, 'Confidentialité', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/privacy');
                  }),
                  _drawerItem(Icons.help_rounded, 'Aide & Support', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/help');
                  }),
                  _drawerItem(Icons.flag_rounded, 'Missions', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/missions');
                  }),
                  _drawerItem(Icons.menu_book_rounded, 'Guide de Tri', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/sorting-guide');
                  }),
                  const Divider(color: AppColors.glassBorder, height: 1),
                  _drawerItem(Icons.logout_rounded, 'Déconnexion', () async {
                    Navigator.pop(context);
                    await auth.logout();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/landing');
                    }
                  }, color: AppColors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user, AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.green.withValues(alpha: 0.2),
            AppColors.dark,
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.green.withValues(alpha: 0.15),
              border: Border.all(color: AppColors.green, width: 2),
              image: user?.photoUrl != null
                  ? DecorationImage(image: NetworkImage(user!.photoUrl!), fit: BoxFit.cover)
                  : null,
            ),
            child: user?.photoUrl == null
                ? const Icon(Icons.person_rounded, color: AppColors.green, size: 28)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Utilisateur',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.uniqueId ?? '',
                  style: const TextStyle(color: AppColors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.grey, size: 22),
      title: Text(
        label,
        style: TextStyle(
          color: color ?? AppColors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      horizontalTitleGap: 12,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }
}
