import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../services/mock_data.dart';
import '../services/chat_service.dart';
import '../theme/app_theme.dart';
import '../utils/extensions.dart';

class UserProfileScreen extends StatelessWidget {
  final UserModel user;

  const UserProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final posts = MockData.posts.where((p) => p.userId == user.id).toList();
    final roleColor = user.role == 'collecteur'
        ? AppColors.blue
        : user.role == 'trieur'
            ? AppColors.yellow
            : AppColors.orange;
    final hasLocation = user.latitude != null && user.longitude != null;

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: Text(user.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileBanner(user, roleColor, hasLocation),
            _buildStatsRow(user, roleColor),
            if (hasLocation) _buildMiniMap(user),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text('Publications', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                    child: Text('${posts.length}', style: const TextStyle(color: AppColors.green, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (posts.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.photo_library_outlined, size: 48, color: AppColors.grey.withValues(alpha: 0.5)),
                    const SizedBox(height: 12),
                    const Text('Aucune publication', style: TextStyle(color: AppColors.grey)),
                  ],
                ),
              )
            else
              ...posts.map((p) => _buildPostCard(p)),
            const SizedBox(height: 24),
            _buildChatButton(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileBanner(UserModel user, Color roleColor, bool hasLocation) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [roleColor.withValues(alpha: 0.15), AppColors.dark],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.dark,
              border: Border.all(color: roleColor, width: 3),
              image: user.photoUrl != null
                  ? DecorationImage(image: NetworkImage(user.photoUrl!), fit: BoxFit.cover)
                  : null,
            ),
            child: user.photoUrl == null
                ? Icon(Icons.person_rounded, color: roleColor, size: 40)
                : null,
          ),
          const SizedBox(height: 12),
          Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(user.uniqueId, style: const TextStyle(color: AppColors.grey, fontSize: 13)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_outline_rounded, size: 16, color: roleColor),
                const SizedBox(width: 6),
                Text(user.roleLabel, style: TextStyle(color: roleColor, fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(UserModel user, Color roleColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _statCard(Icons.star_rounded, user.rating.toStringAsFixed(1), 'Note', AppColors.yellow),
          const SizedBox(width: 8),
          _statCard(Icons.check_circle_rounded, '${user.completedMissions}', 'Missions', AppColors.green),
          const SizedBox(width: 8),
          _statCard(Icons.stars_rounded, '${user.points} pts', 'Points', AppColors.yellow),
          const SizedBox(width: 8),
          _statCard(Icons.location_on_rounded, user.latitude != null ? '${user.latitude!.toStringAsFixed(2)}, ${user.longitude!.toStringAsFixed(2)}' : '--', 'Position', AppColors.blue, flex: 2),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String value, String label, Color color, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.softBlack,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: Colors.white, fontSize: flex > 1 ? 10 : 13, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis, maxLines: 1),
            Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMap(UserModel user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.glassBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(user.latitude!, user.longitude!),
            initialZoom: 14,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.recylpay.mboacycle',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(user.latitude!, user.longitude!),
                  child: const Icon(Icons.location_on_rounded, color: AppColors.green, size: 36),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(PostModel post) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.softBlack,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              child: Image.network(
                post.imageUrl,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 120,
                  color: AppColors.dark,
                  child: const Center(child: Icon(Icons.image_outlined, color: AppColors.grey, size: 32)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.wasteTypes.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Wrap(
                        spacing: 4,
                        children: post.wasteTypes.map((t) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(t, style: const TextStyle(color: AppColors.green, fontSize: 10, fontWeight: FontWeight.w500)),
                        )).toList(),
                      ),
                    ),
                  if (post.description != null)
                    Text(post.description!, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.favorite_rounded, size: 14, color: post.isLiked ? AppColors.red : AppColors.grey),
                      const SizedBox(width: 3),
                      Text('${post.likes}', style: const TextStyle(color: AppColors.grey, fontSize: 11)),
                      const SizedBox(width: 14),
                      const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: AppColors.grey),
                      const SizedBox(width: 3),
                      Text('${post.commentsCount}', style: const TextStyle(color: AppColors.grey, fontSize: 11)),
                      const Spacer(),
                      Text(post.createdAt.toRelative(), style: const TextStyle(color: AppColors.grey, fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          final chatService = ChatService();
          chatService.getOrCreateConversation(user.id, user.name, user.photoUrl);
          Navigator.pushNamed(context, '/messages');
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.green, Color(0xFF27AE60)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_rounded, color: Colors.white, size: 22),
              SizedBox(width: 10),
              Text('Discuter avec cet utilisateur', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
