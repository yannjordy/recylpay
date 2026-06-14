import 'package:flutter/material.dart';

class EcoService {
  static final EcoService _instance = EcoService._();
  factory EcoService() => _instance;
  EcoService._();

  double get totalCO2Saved => 2845.5;
  int get totalTreesEquivalent => 142;
  int get totalWasteCollected => 12580;
  int get totalWaterSaved => 189000;
  int get totalEnergySaved => 84500;
  int get userRank => 42;
  int get totalUsers => 1520;

  double get monthlyCO2 => 312.8;
  int get monthlyWaste => 1580;
  int get monthlyMissions => 47;

  List<EcoMilestone> get milestones => [
    EcoMilestone('Première collecte', '10 kg', true, Icons.eco_rounded),
    EcoMilestone('Collecteur Bronze', '100 kg', true, Icons.emoji_events_rounded),
    EcoMilestone('Collecteur Argent', '500 kg', true, Icons.emoji_events_rounded),
    EcoMilestone('Collecteur Or', '1 000 kg', false, Icons.emoji_events_rounded),
    EcoMilestone('Défenseur de l\'environnement', '5 000 kg', false, Icons.public_rounded),
    EcoMilestone('Mission accomplie', '50 missions', true, Icons.task_alt_rounded),
    EcoMilestone('Livreur pro', '100 livraisons', false, Icons.local_shipping_rounded),
    EcoMilestone('Impact vert', '1T CO2 sauvé', false, Icons.forest_rounded),
  ];

  Map<String, double> get wasteBreakdown => {
    'Plastique': 35.0,
    'Métal': 20.0,
    'Carton': 18.0,
    'Verre': 12.0,
    'Papier': 8.0,
    'Autre': 7.0,
  };

  List<Map<String, dynamic>> get monthlyStats {
    final months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin'];
    final data = [120, 280, 450, 680, 920, 1250];
    return List.generate(months.length, (i) => {
      'month': months[i],
      'kg': data[i],
      'co2': (data[i] * 0.226).toStringAsFixed(1),
    });
  }
}

class EcoMilestone {
  final String title;
  final String requirement;
  final bool achieved;
  final IconData icon;

  EcoMilestone(this.title, this.requirement, this.achieved, this.icon);
}
