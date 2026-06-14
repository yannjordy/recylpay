import 'package:flutter/material.dart';
import '../services/eco_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/stat_card.dart';
import '../utils/responsive.dart';

class EcoImpactScreen extends StatelessWidget {
  const EcoImpactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eco = EcoService();

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: const Text('Impact Écologique'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: DesktopScaffold(child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroCard(context, eco),
            const SizedBox(height: 20),
            Text('Ce mois-ci', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: StatCard(label: 'CO₂ sauvé', value: '${eco.monthlyCO2} kg', icon: Icons.cloud_rounded, color: AppColors.green)),
                const SizedBox(width: 12),
                Expanded(child: StatCard(label: 'Déchets', value: '${eco.monthlyWaste} kg', icon: Icons.recycling_rounded, color: AppColors.blue)),
                const SizedBox(width: 12),
                Expanded(child: StatCard(label: 'Missions', value: '${eco.monthlyMissions}', icon: Icons.task_alt_rounded, color: AppColors.yellow)),
              ],
            ),
            const SizedBox(height: 24),
            Text('Progression mensuelle', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _buildMonthlyChart(context, eco),
            const SizedBox(height: 24),
            Text('Répartition des déchets', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _buildWasteBreakdown(context, eco),
            const SizedBox(height: 24),
            Text('Succès et Récompenses', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...eco.milestones.map((m) => _buildMilestone(context, m)),
            const SizedBox(height: 32),
            _buildGlobalRank(context, eco),
          ],
        ),
      )),
    );
  }

  Widget _buildHeroCard(BuildContext context, EcoService eco) {
    return GlassContainer(
      width: double.infinity,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text('Impact total', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text('${eco.totalCO2Saved.toStringAsFixed(0)} kg', style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.green, fontSize: 40, fontWeight: FontWeight.bold,
                )),
                const Text('CO₂ épargné', style: TextStyle(color: AppColors.grey, fontSize: 13)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _impactItem(Icons.forest_rounded, '${eco.totalTreesEquivalent}', 'Arbres', AppColors.green),
                    _impactItem(Icons.water_drop_rounded, '${eco.totalWaterSaved ~/ 1000}k L', 'Eau', AppColors.blue),
                    _impactItem(Icons.bolt_rounded, '${eco.totalEnergySaved ~/ 1000}k kWh', 'Énergie', AppColors.yellow),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _impactItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
      ],
    );
  }

  Widget _buildMonthlyChart(BuildContext context, EcoService eco) {
    final stats = eco.monthlyStats;
    final maxKg = stats.fold<double>(0, (m, s) => (s['kg'] as int) > m ? (s['kg'] as int).toDouble() : m);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softBlack,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: stats.map((s) {
          final kg = s['kg'] as int;
          final height = (kg / maxKg) * 120;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$kg kg', style: const TextStyle(color: AppColors.green, fontSize: 10, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Container(
                width: 28,
                height: height.clamp(8, 120),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [AppColors.green, Color(0xFF27AE60)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 4),
              Text(s['month'] as String, style: const TextStyle(color: AppColors.grey, fontSize: 10)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWasteBreakdown(BuildContext context, EcoService eco) {
    final breakdown = eco.wasteBreakdown;
    final colors = [AppColors.green, AppColors.blue, AppColors.yellow, AppColors.orange, AppColors.red, AppColors.grey];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softBlack,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: breakdown.entries.map((e) {
          final i = breakdown.keys.toList().indexOf(e.key);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(width: 12, height: 12, decoration: BoxDecoration(color: colors[i % colors.length], shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(child: Text(e.key, style: const TextStyle(fontSize: 13))),
                Text('${e.value.toStringAsFixed(0)}%', style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMilestone(BuildContext context, EcoMilestone m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: m.achieved ? AppColors.green.withValues(alpha: 0.08) : AppColors.softBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: m.achieved ? AppColors.green.withValues(alpha: 0.3) : AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Icon(m.icon, color: m.achieved ? AppColors.green : AppColors.grey, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.title, style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: m.achieved ? AppColors.white : AppColors.grey,
                )),
                Text(m.requirement, style: TextStyle(color: AppColors.grey, fontSize: 12)),
              ],
            ),
          ),
          Icon(
            m.achieved ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: m.achieved ? AppColors.green : AppColors.grey,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalRank(BuildContext context, EcoService eco) {
    return GlassContainer(
      width: double.infinity,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.yellow.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.leaderboard_rounded, color: AppColors.yellow, size: 32),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Classement', style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('#${eco.userRank} sur ${eco.totalUsers} utilisateurs', style: const TextStyle(color: AppColors.grey, fontSize: 13)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('Top 5%', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
