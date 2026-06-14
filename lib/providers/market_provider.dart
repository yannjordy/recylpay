import 'package:flutter/material.dart';
import '../models/recycling_company_model.dart';

class MarketProvider extends ChangeNotifier {
  List<RecyclingCompany> _allCompanies = [];
  List<RecyclingCompany> get allCompanies => _allCompanies;
  List<RecyclingCompany> get activeCompanies =>
      _allCompanies.where((c) => c.materials.isNotEmpty).toList();

  String _selectedCity = 'Toutes';
  String get selectedCity => _selectedCity;
  set selectedCity(String v) {
    _selectedCity = v;
    notifyListeners();
  }

  String _selectedMaterial = 'Tous';
  String get selectedMaterial => _selectedMaterial;
  set selectedMaterial(String v) {
    _selectedMaterial = v;
    notifyListeners();
  }

  MarketProvider() {
    _seedCompanies();
  }

  List<RecyclingCompany> get filteredCompanies {
    var list = _allCompanies;
    if (_selectedCity != 'Toutes') {
      list = list.where((c) => c.city.toLowerCase().contains(_selectedCity.toLowerCase())).toList();
    }
    if (_selectedMaterial != 'Tous') {
      list = list.where((c) => c.materials.any((m) =>
          m.name.toLowerCase().contains(_selectedMaterial.toLowerCase()))).toList();
    }
    return list;
  }

  List<String> get availableCities {
    final s = _allCompanies.map((c) => c.city).toSet().toList();
    s.sort();
    return ['Toutes', ...s];
  }

  List<String> get availableMaterials {
    final s = <String>{};
    for (final c in _allCompanies) {
      for (final m in c.materials) {
        s.add(m.name);
      }
    }
    final l = s.toList();
    l.sort();
    return ['Tous', ...l];
  }

  double? estimateRevenue(String materialName, double weightKg) {
    double? bestPrice;
    for (final c in _allCompanies) {
      for (final m in c.materials) {
        if (m.name.toLowerCase().contains(materialName.toLowerCase())) {
          final p = m.priceMax ?? m.priceMin;
          if (p != null && (bestPrice == null || p > bestPrice)) {
            bestPrice = p;
          }
        }
      }
    }
    if (bestPrice == null) return null;
    return bestPrice * weightKg;
  }

  RecyclingCompany? bestBuyerFor(String materialName) {
    RecyclingCompany? best;
    double? bestPrice;
    for (final c in _allCompanies) {
      for (final m in c.materials) {
        if (m.name.toLowerCase().contains(materialName.toLowerCase())) {
          final p = m.priceMax ?? m.priceMin;
          if (p != null && (bestPrice == null || p > bestPrice)) {
            bestPrice = p;
            best = c;
          }
        }
      }
    }
    return best;
  }

  void _seedCompanies() {
    _allCompanies = [
      const RecyclingCompany(
        id: 'rc_1',
        name: 'ECOGREEN RECYCLING',
        city: 'Douala - Bonabéri',
        address: 'Bonabéri, Douala',
        latitude: 4.071,
        longitude: 9.681,
        website: 'https://www.ecogreenrecycling.org/',
        phone: '+237 6XX XXX XXX',
        materials: [
          AcceptedMaterial(name: 'PET', priceMin: 150, priceMax: 250, quality: 'Trié', minWeight: 10),
          AcceptedMaterial(name: 'PEHD', priceMin: 120, priceMax: 200, quality: 'Trié', minWeight: 10),
        ],
        services: ['Achat', 'Ramassage entreprise'],
        rating: 4.2,
        hours: 'Lun-Sam 08:00-18:00',
      ),
      const RecyclingCompany(
        id: 'rc_2',
        name: 'NAMé Recycling',
        city: 'Douala',
        address: 'Douala',
        latitude: 4.058,
        longitude: 9.735,
        website: 'http://www.name-recycling.com/',
        phone: '+237 6XX XXX XXX',
        materials: [
          AcceptedMaterial(name: 'PET', priceNote: 'Variable selon quantité', quality: 'Trié'),
          AcceptedMaterial(name: 'HDPE', priceNote: 'Variable selon quantité', quality: 'Trié'),
          AcceptedMaterial(name: 'LDPE', priceNote: 'Variable selon quantité', quality: 'Trié'),
        ],
        services: ['Achat', 'Collecte', 'Transformation'],
        rating: 4.5,
        hours: 'Lun-Ven 08:00-17:00',
      ),
      const RecyclingCompany(
        id: 'rc_3',
        name: 'LONG METAL',
        city: 'Douala',
        address: 'Douala',
        latitude: 4.045,
        longitude: 9.702,
        materials: [
          AcceptedMaterial(name: 'Ferraille', priceMin: 80, priceMax: 300, quality: 'Trié', minWeight: 50),
          AcceptedMaterial(name: 'Aluminium', priceMin: 500, priceMax: 1500, quality: 'Trié', minWeight: 20),
          AcceptedMaterial(name: 'Métaux divers', priceMin: 100, priceMax: 500, quality: 'Trié', minWeight: 50),
        ],
        services: ['Achat', 'Ramassage'],
        rating: 4.0,
        hours: 'Lun-Sam 07:00-18:00',
      ),
      const RecyclingCompany(
        id: 'rc_4',
        name: 'Wastewise Cameroon',
        city: 'Douala - Bonabéri',
        address: 'Bonabéri, Douala',
        latitude: 4.078,
        longitude: 9.688,
        materials: [
          AcceptedMaterial(name: 'Plastiques divers', priceNote: 'Sur demande'),
          AcceptedMaterial(name: 'Déchets recyclables', priceNote: 'Sur demande'),
        ],
        services: ['Collecte', 'Conseil'],
        rating: 3.8,
        hours: 'Lun-Ven 08:00-17:00',
      ),
      const RecyclingCompany(
        id: 'rc_5',
        name: 'AVGO Recycling',
        city: 'Yaoundé - Ahala',
        address: 'Ahala, Yaoundé',
        latitude: 3.872,
        longitude: 11.516,
        materials: [
          AcceptedMaterial(name: 'Plastiques', priceNote: 'Sur demande'),
          AcceptedMaterial(name: 'Déchets recyclables', priceNote: 'Sur demande'),
        ],
        services: ['Achat', 'Collecte'],
        rating: 4.1,
        hours: 'Lun-Sam 08:00-17:30',
      ),
      const RecyclingCompany(
        id: 'rc_6',
        name: 'Ets REC DJIMELI',
        city: 'Douala',
        address: 'Douala',
        latitude: 4.038,
        longitude: 9.718,
        materials: [
          AcceptedMaterial(name: 'Déchets recyclables divers', priceNote: 'Sur demande'),
        ],
        services: ['Achat'],
        rating: 3.5,
        hours: 'Lun-Sam 08:00-18:00',
      ),
      const RecyclingCompany(
        id: 'rc_7',
        name: 'Green Energy Company',
        city: 'Douala',
        address: 'Douala',
        latitude: 4.062,
        longitude: 9.728,
        materials: [
          AcceptedMaterial(name: 'Plastiques', priceNote: 'Sur demande'),
          AcceptedMaterial(name: 'Déchets valorisables', priceNote: 'Sur demande'),
        ],
        services: ['Achat', 'Valorisation'],
        rating: 3.9,
        hours: 'Lun-Ven 08:00-17:00',
      ),
      const RecyclingCompany(
        id: 'rc_8',
        name: 'TRI-ACTION Cameroun',
        city: 'Yaoundé',
        address: 'Centre-ville, Yaoundé',
        latitude: 3.866,
        longitude: 11.518,
        materials: [
          AcceptedMaterial(name: 'Carton', priceMin: 50, priceMax: 100, quality: 'Compressé', minWeight: 20),
          AcceptedMaterial(name: 'Papier', priceMin: 30, priceMax: 80, quality: 'Trié', minWeight: 20),
        ],
        services: ['Achat', 'Ramassage'],
        rating: 4.3,
        hours: 'Lun-Ven 07:30-17:30',
      ),
      const RecyclingCompany(
        id: 'rc_9',
        name: 'BIOCOMPOST SARL',
        city: 'Bafoussam',
        address: 'Quartier Djeleng, Bafoussam',
        latitude: 5.478,
        longitude: 10.416,
        materials: [
          AcceptedMaterial(name: 'Déchets organiques', priceMin: 25, priceMax: 75, quality: 'Trié', minWeight: 100),
        ],
        services: ['Achat', 'Compostage'],
        rating: 4.0,
        hours: 'Lun-Sam 08:00-17:00',
      ),
      const RecyclingCompany(
        id: 'rc_10',
        name: 'LIMBE RECYCLAGE',
        city: 'Limbe',
        address: 'Limbe Centre',
        latitude: 4.024,
        longitude: 9.215,
        materials: [
          AcceptedMaterial(name: 'Verre', priceMin: 40, priceMax: 100, quality: 'Propre', minWeight: 10),
          AcceptedMaterial(name: 'PET', priceMin: 130, priceMax: 200, quality: 'Trié', minWeight: 5),
        ],
        services: ['Achat', 'Collecte'],
        rating: 4.4,
        hours: 'Lun-Sam 08:00-18:00',
      ),
    ];
  }
}
