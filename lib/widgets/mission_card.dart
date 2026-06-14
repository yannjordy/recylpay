import 'package:flutter/material.dart';
import '../models/mission_model.dart';
import '../theme/app_theme.dart';
import '../utils/extensions.dart';

class MissionCard extends StatelessWidget {
  final MissionModel mission;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;

  const MissionCard({
    super.key,
    required this.mission,
    this.onTap,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _typeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    mission.typeLabel,
                    style: TextStyle(
                      color: _typeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    mission.statusLabel,
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (mission.commission != null) ...[
              Text(
                mission.commission!.toFCFA(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.green,
                      fontSize: 20,
                    ),
              ),
              const SizedBox(height: 4),
            ],
            if (mission.pickupAddress != null)
              Text(
                mission.pickupAddress!,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (mission.distance != null) ...[
              const SizedBox(height: 4),
              Text(
                '${mission.distance!.toStringAsFixed(1)} km',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.yellow,
                    ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              mission.createdAt.toRelative(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                  ),
            ),
            if (mission.status == 'available' && onAccept != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Accepter la mission',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color get _typeColor {
    switch (mission.type) {
      case 'collecte':
        return AppColors.green;
      case 'livraison':
        return AppColors.blue;
      case 'tri':
        return AppColors.yellow;
      default:
        return AppColors.grey;
    }
  }

  Color get _statusColor {
    switch (mission.status) {
      case 'available':
        return AppColors.green;
      case 'accepted':
        return AppColors.blue;
      case 'in_progress':
        return AppColors.orange;
      case 'completed':
        return AppColors.green;
      case 'cancelled':
        return AppColors.red;
      default:
        return AppColors.grey;
    }
  }
}
