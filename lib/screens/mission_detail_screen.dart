import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mission_model.dart';
import '../providers/auth_provider.dart';
import '../providers/mission_provider.dart';
import '../theme/app_theme.dart';
import '../utils/extensions.dart';

class MissionDetailScreen extends StatelessWidget {
  final MissionModel mission;
  const MissionDetailScreen({super.key, required this.mission});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isMyMission = auth.user?.name == mission.creatorName;
    final canAccept = mission.status == 'available';
    final canComplete = mission.status == 'accepted' || mission.status == 'in_progress';

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(mission.typeLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Creator profile section
            _buildCreatorSection(context),
            const SizedBox(height: 24),

            // Photos
            if (mission.imageUrls.isNotEmpty) ...[
              const Text('Photos', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildPhotoRow(context),
              const SizedBox(height: 20),
            ],

            // Description
            if (mission.description.isNotEmpty) ...[
              const Text('Description', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.softBlack,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(mission.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
              ),
              const SizedBox(height: 20),
            ],

            // Details
            const Text('Détails', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _detailTile(Icons.location_on_rounded, 'Ramassage', mission.pickupAddress ?? 'Non spécifié'),
            _detailTile(Icons.flag_rounded, 'Dépôt', mission.dropAddress ?? 'Non spécifié'),
            if (mission.distance != null)
              _detailTile(Icons.speed_rounded, 'Distance', '${mission.distance!.toStringAsFixed(1)} km'),
            if (mission.commission != null)
              _detailTile(Icons.monetization_on_rounded, 'Commission', mission.commission!.toFCFA()),
            _detailTile(Icons.calendar_today_rounded, 'Publiée', mission.createdAt.toRelative()),
            if (mission.acceptedAt != null)
              _detailTile(Icons.check_circle_rounded, 'Acceptée', mission.acceptedAt!.toRelative()),
            if (mission.completedAt != null)
              _detailTile(Icons.done_all_rounded, 'Terminée', mission.completedAt!.toRelative()),

            const SizedBox(height: 28),

            // Actions
            if (canAccept)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _acceptMission(context),
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Accepter la mission'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  ),
                ),
              ),
            if (canComplete)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _completeMission(context),
                  icon: const Icon(Icons.done_all_rounded),
                  label: const Text('Terminer la mission'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  ),
                ),
              ),
            if (mission.status == 'completed')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: AppColors.green, size: 20),
                    SizedBox(width: 8),
                    Text('Mission terminée', style: TextStyle(color: AppColors.green, fontSize: 15, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatorSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.green.withValues(alpha: 0.15),
            backgroundImage: mission.creatorPhotoUrl != null ? NetworkImage(mission.creatorPhotoUrl!) : null,
            child: mission.creatorPhotoUrl == null
                ? Icon(Icons.person_rounded, color: AppColors.green, size: 28)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mission.creatorName ?? 'Anonyme',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(mission.creatorRole ?? 'Membre',
                          style: const TextStyle(color: AppColors.green, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.star_rounded, color: AppColors.yellow, size: 16),
                    const SizedBox(width: 2),
                    Text('4.5', style: TextStyle(color: AppColors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoRow(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: mission.imageUrls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          return GestureDetector(
            onTap: () => _showFullscreen(context, i),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                mission.imageUrls[i],
                width: 260, height: 180, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 260, height: 180,
                  color: AppColors.softBlack,
                  child: const Icon(Icons.broken_image_rounded, color: AppColors.grey),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFullscreen(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullScreenGallery(images: mission.imageUrls, initialIndex: index),
      ),
    );
  }

  Widget _detailTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.grey, size: 18),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _acceptMission(BuildContext context) async {
    await context.read<MissionProvider>().acceptMission(mission.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mission acceptée !'), backgroundColor: AppColors.green),
      );
      Navigator.pop(context);
    }
  }

  void _completeMission(BuildContext context) async {
    await context.read<MissionProvider>().completeMission(mission.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mission terminée !'), backgroundColor: AppColors.green),
      );
      Navigator.pop(context);
    }
  }
}

class _FullScreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  const _FullScreenGallery({required this.images, required this.initialIndex});

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late PageController _pageCtrl;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageCtrl = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('${_currentIndex + 1} / ${widget.images.length}',
            style: const TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: PageView.builder(
          controller: _pageCtrl,
          itemCount: widget.images.length,
          onPageChanged: (i) => setState(() => _currentIndex = i),
          itemBuilder: (ctx, i) => InteractiveViewer(
            child: Center(
              child: Image.network(
                widget.images[i],
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_rounded, color: AppColors.grey, size: 64),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
