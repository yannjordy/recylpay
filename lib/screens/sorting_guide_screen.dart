import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../utils/responsive.dart';
import '../widgets/glass_container.dart';

class SortingGuideScreen extends StatefulWidget {
  const SortingGuideScreen({super.key});

  @override
  State<SortingGuideScreen> createState() => _SortingGuideScreenState();
}

class _SortingGuideScreenState extends State<SortingGuideScreen> {
  static const Map<String, IconData> _icons = {
    'PET (Plastique)': Icons.local_drink_rounded,
    'PEHD (Plastique dur)': Icons.cleaning_services_rounded,
    'Aluminium': Icons.coffee_rounded,
    'Carton': Icons.widgets_rounded,
    'Verre': Icons.local_bar_rounded,
    'Papier': Icons.description_rounded,
    'Fer/Métal': Icons.build_rounded,
    'Électronique': Icons.devices_rounded,
    'Pneu': Icons.circle_rounded,
    'Huile usagée': Icons.water_drop_rounded,
  };

  static const Map<String, Color> _colors = {
    'PET (Plastique)': AppColors.green,
    'PEHD (Plastique dur)': Colors.teal,
    'Aluminium': AppColors.blue,
    'Carton': Colors.amber,
    'Verre': Colors.cyan,
    'Papier': AppColors.yellow,
    'Fer/Métal': AppColors.grey,
    'Électronique': Colors.purple,
    'Pneu': AppColors.red,
    'Huile usagée': AppColors.orange,
  };

  static const Map<String, List<String>> _tips = {
    'PET (Plastique)': [
      'Rincez les bouteilles',
      'Enlevez les bouchons',
      'Aplatissez pour gagner de la place',
    ],
    'PEHD (Plastique dur)': [
      'Rincez les contenants',
      'Séparez les couvercles',
      'Les bidons et flacons sont acceptés',
    ],
    'Aluminium': [
      'Nettoyez les canettes',
      'Aplatissez-les',
      'Les barquettes propres sont acceptées',
    ],
    'Carton': [
      'Aplatissez les cartons',
      'Enlevez le ruban adhésif',
      'Gardez au sec',
    ],
    'Verre': [
      'Rincez les bocaux',
      'Séparez les couvercles',
      'Ne mélangez pas avec la vaisselle',
    ],
    'Papier': [
      'Gardez les papiers secs',
      'Enlevez les agrafes',
      'Les journaux et magazines sont acceptés',
    ],
    'Fer/Métal': [
      'Nettoyez les boîtes',
      'Les canettes de conserve sont acceptées',
      'Apportez en grande quantité',
    ],
    'Électronique': [
      'Ne jetez jamais à la poubelle',
      'Apportez dans un point de collecte',
      'Contient des métaux précieux',
    ],
    'Pneu': [
      'Dépôt en centre agréé',
      'Peut être transformé en pavés',
      'Ne brûlez jamais les pneus',
    ],
    'Huile usagée': [
      'Stockez dans un bidon fermé',
      'Ne versez pas dans l\'évier',
      'Apportez dans une déchèterie',
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Guide de Tri'),
      ),
      body: DesktopScaffold(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            for (final category in Constants.wasteCategories)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCategoryCard(category),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Guide de Tri',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Apprenez à bien trier vos déchets',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String category) {
    final icon = _icons[category]!;
    final color = _colors[category]!;
    final tips = _tips[category]!;
    final price = Constants.defaultPrices[category] ?? 0;

    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              _buildRecyclableBadge(color),
            ],
          ),
          const SizedBox(height: 12),
          for (final tip in tips)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.grey,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.monetization_on_outlined, color: AppColors.green, size: 16),
              const SizedBox(width: 4),
              Text(
                'Prix au kg: $price F',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecyclableBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            'Recyclable',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
