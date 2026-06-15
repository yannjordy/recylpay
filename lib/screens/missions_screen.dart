import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mission_provider.dart';
import '../models/mission_model.dart';
import '../theme/app_theme.dart';
import '../utils/extensions.dart';
import '../widgets/pill_button.dart';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  String _selectedFilter = 'Toutes';
  final List<String> _filters = ['Toutes', 'collecte', 'livraison', 'tri'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MissionProvider>().loadMissions();
    });
  }

  List<MissionModel> _filteredMissions(List<MissionModel> missions) {
    if (_selectedFilter == 'Toutes') return missions;
    return missions.where((m) => m.type == _selectedFilter).toList();
  }

  Future<void> _acceptMission(MissionModel mission) async {
    await context.read<MissionProvider>().acceptMission(mission.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mission acceptée !'),
          backgroundColor: AppColors.green,
        ),
      );
    }
  }

  Future<void> _completeMission(MissionModel mission) async {
    await context.read<MissionProvider>().completeMission(mission.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mission terminée !'),
          backgroundColor: AppColors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final missionProv = context.watch<MissionProvider>();
    final filtered = _filteredMissions(missionProv.missions);
    final count = filtered.length;

    return Container(
      color: AppColors.dark,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(count),
            _buildFilterChips(),
            Expanded(
              child: missionProv.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : missionProv.error != null
                      ? _buildError(missionProv.error!)
                      : filtered.isEmpty
                          ? _buildEmpty()
                          : _buildList(filtered),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          const Text(
            'Missions disponibles',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: AppColors.green,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 56,
      margin: const EdgeInsets.only(top: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          final label = index == 0 ? 'Toutes' : _filterLabel(filter);

          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? _filterColor(filter).withValues(alpha: 0.15) : AppColors.softBlack,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: isSelected ? _filterColor(filter) : AppColors.glassBorder,
                  width: isSelected ? 1.5 : 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_filterIcon(filter), size: 16, color: isSelected ? _filterColor(filter) : AppColors.grey),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? _filterColor(filter) : AppColors.grey,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _filterLabel(String filter) {
    switch (filter) {
      case 'collecte': return 'Collecte';
      case 'livraison': return 'Livraison';
      case 'tri': return 'Tri';
      default: return filter;
    }
  }

  Color _filterColor(String filter) {
    switch (filter) {
      case 'collecte': return AppColors.green;
      case 'livraison': return AppColors.blue;
      case 'tri': return AppColors.yellow;
      default: return AppColors.green;
    }
  }

  IconData _filterIcon(String filter) {
    switch (filter) {
      case 'collecte': return Icons.delete_outline_rounded;
      case 'livraison': return Icons.local_shipping_rounded;
      case 'tri': return Icons.sort_rounded;
      default: return Icons.recycling_rounded;
    }
  }

  Widget _buildList(List<MissionModel> missions) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
      itemCount: missions.length,
      itemBuilder: (context, index) => _buildMissionCard(missions[index]),
    );
  }

  Widget _buildMissionCard(MissionModel mission) {
    final bool canAccept = mission.status == 'available';
    final bool canComplete = mission.status == 'accepted' || mission.status == 'in_progress';
    final bool isCompleted = mission.status == 'completed';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _typeColor(mission.type).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_typeIcon(mission.type), color: _typeColor(mission.type), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission.typeLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      mission.createdAt.toRelative(),
                      style: const TextStyle(color: AppColors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(mission),
            ],
          ),
          const SizedBox(height: 14),
          _buildAddressRow(Icons.location_on_rounded, mission.pickupAddress ?? 'Adresse de ramassage'),
          const SizedBox(height: 6),
          _buildAddressRow(Icons.flag_rounded, mission.dropAddress ?? 'Adresse de dépôt'),
          const SizedBox(height: 12),
          Row(
            children: [
              if (mission.distance != null)
                _buildInfoChip(Icons.speed_rounded, '${mission.distance!.toStringAsFixed(1)} km', AppColors.yellow),
              if (mission.distance != null && mission.commission != null)
                const SizedBox(width: 8),
              if (mission.commission != null)
                _buildInfoChip(Icons.monetization_on_rounded, mission.commission!.toFCFA(), AppColors.green),
            ],
          ),
          if (canAccept && !isCompleted) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: PillButton(
                label: 'Accepter',
                icon: Icons.check_circle_outline_rounded,
                onTap: () => _acceptMission(mission),
              ),
            ),
          ],
          if (canComplete && !isCompleted) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: PillButton(
                label: 'Terminer',
                icon: Icons.done_all_rounded,
                color: AppColors.blue,
                onTap: () => _completeMission(mission),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddressRow(IconData icon, String address) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            address,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(MissionModel mission) {
    final isTerminee = mission.status == 'completed';
    Color color;
    String label;

    if (isTerminee) {
      color = AppColors.grey;
      label = 'Terminée';
    } else if (mission.status == 'accepted' || mission.status == 'in_progress') {
      color = AppColors.blue;
      label = 'En cours';
    } else {
      color = AppColors.green;
      label = 'Disponible';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'collecte': return AppColors.green;
      case 'livraison': return AppColors.blue;
      case 'tri': return AppColors.yellow;
      default: return AppColors.grey;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'collecte': return Icons.delete_outline_rounded;
      case 'livraison': return Icons.local_shipping_rounded;
      case 'tri': return Icons.sort_rounded;
      default: return Icons.recycling_rounded;
    }
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.recycling_rounded,
            size: 72,
            color: AppColors.grey.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucune mission disponible',
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Revenez plus tard pour découvrir\nles nouvelles missions près de chez vous.',
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.red),
            const SizedBox(height: 12),
            Text(
              error,
              style: const TextStyle(color: AppColors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            PillButton(
              label: 'Réessayer',
              icon: Icons.refresh_rounded,
              onTap: () => context.read<MissionProvider>().loadMissions(),
            ),
          ],
        ),
      ),
    );
  }
}
