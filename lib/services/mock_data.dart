import 'package:latlong2/latlong.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/mission_model.dart';
import '../models/transaction_model.dart';
import '../models/pollution_report_model.dart';
import '../models/waste_collection_model.dart';
import '../utils/constants.dart';

final _names = [
  'Jean-Paul Mbarga', 'Marie-Claire Ngo', 'Patrick Essomba', 'Sarah Tchinda',
  'David Kameni', 'Esther Nkwi', 'François Bikoi', 'Grace Mbah',
  'Hervé Ngane', 'Irene Njock', 'Jacques Simo', 'Karine Eyanga',
  'Luc Mvondo', 'Marthe Biya', 'Nicolas Eyebe', 'Odile Mendo',
  'Paul Atanga', 'Rachel Nkeng', 'Serge Mpouma', 'Therese Ebogo',
  'Alain Mfouapon', 'Beatrice Nkwi', 'Christian Ayissi', 'Diane Mbock',
  'Emmanuel Tchakounte', 'Fabrice Kameni', 'Georges Ngassa', 'Helene Mbarga',
  'Ismael Bikoka', 'Josephine Eyanga', 'Kevin Mbah', 'Laurette Simo',
  'Michel Nkengue', 'Nancy Eyebe', 'Olivier Mpondo', 'Prisca Ngo',
  'Quentin Mballa', 'Rose Mbarga', 'Stephane Tchinda', 'Ursule Nkwi',
  'Valentin Eyanga', 'William Mbah', 'Xavier Ngane', 'Yvette Simo',
  'Zacharie Bikoi', 'Aicha Moussa', 'Benoit Nkeng', 'Charlotte Eyanga',
  'Daniel Mbah', 'Edwige Ngo',
];

final _roles = ['collecteur', 'trieur', 'livreur'];

final _cities = [
  ('Douala', 4.0511, 9.7679), ('Yaoundé', 3.8480, 11.5021),
  ('Bafoussam', 5.4798, 10.4194), ('Garoua', 9.3019, 13.3977),
  ('Maroua', 10.5918, 14.3159), ('Bamenda', 5.9597, 10.1460),
  ('Kribi', 2.9435, 9.9099), ('Limbe', 4.0147, 9.2179),
  ('Nkongsamba', 4.9546, 9.9315), ('Ebolowa', 2.9048, 11.1500),
  ('Kumba', 4.6361, 9.4419), ('Buea', 4.1567, 9.2383),
  ('Bertoua', 4.5775, 13.6886), ('Ngaoundéré', 7.3264, 13.5848),
  ('Mokolo', 10.7425, 13.8022), ('Edéa', 3.8000, 10.1333),
  ('Dschang', 5.4471, 10.0532), ('Foumban', 5.7200, 10.9100),
  ('Mbouda', 5.6300, 10.2600), ('Tiko', 4.0700, 9.3600),
  ('Mbalmayo', 3.5200, 11.5100), ('Sangmélima', 2.9300, 11.9800),
  ('Mbandjock', 4.4500, 11.9000), ('Obala', 4.1700, 11.5300),
  ('Muyuka', 4.2900, 9.4100), ('Mamfe', 5.7600, 9.3200),
  ('Kumbo', 6.3900, 10.6700), ('Wum', 6.3800, 10.0600),
  ('Guider', 9.9300, 13.9400), ('Yagoua', 10.3400, 15.2300),
  ('Kaele', 10.1000, 14.4500), ('Bogo', 10.7300, 14.6000),
  ('Tchollire', 8.4000, 14.1700), ('Meiganga', 6.5100, 14.3000),
  ('Tibati', 6.4700, 12.6300), ('Banyo', 6.7500, 11.8200),
];

final _collectedTypes = [
  ['Fer/Métal', 'Aluminium', 'Plastique PET'],
  ['Carton', 'Papier', 'Plastique PEHD'],
  ['Verre', 'Électronique'],
  ['Pneu', 'Huile usagée', 'Bois'],
  ['Plastique PET', 'Plastique PEHD', 'Aluminium'],
  ['Tout'],
  ['Fer/Métal', 'Carton', 'Plastique PET'],
  ['Électronique', 'Métal'],
  ['Aluminium', 'Verre', 'Papier'],
  ['Bois', 'Carton', 'Plastique PEHD'],
  ['Plastique PET', 'Plastique PEHD', 'Carton', 'Papier'],
  ['Fer/Métal', 'Aluminium', 'Électronique'],
  ['Verre', 'Bois', 'Pneu'],
  ['Huile usagée', 'Plastique PET'],
  ['Tout'],
  ['Carton', 'Papier', 'Bois'],
];

const _profilePhotoIds = [
  '1769636929354-59165ba73c7e',  // homme, sweatshirt
  '1743871698163-a2e470d8eac7',  // femme foulard, Cameroun
  '1743866356139-579e0df74e55',  // jeune fille, Cameroun
  '1710117045399-0fab00350f4d',  // femme parure masaï
  '1766107349536-c6de9ab38dcd',  // femme tenue traditionnelle, Ghana
  '1770396528756-d463cc7f0a8a',  // jeune femme afro, Gabon
  '1769636930016-5d9f0ca653aa',  // femme t-shirt noir
  '1745690720220-24e337e571c7',  // homme masaï
  '1759300063434-482e4d65f9bf',  // homme barbu Nigeria
];

class MockData {
  static final List<UserModel> users = [];
  static final List<PostModel> posts = [];
  static final List<MissionModel> missions = [];
  static final List<TransactionModel> transactions = [];
  static final List<PollutionReportModel> pollutionReports = [];
  static final List<WasteCollectionModel> collections = [];
  static final Map<String, List<CommentModel>> comments = {};
  static final List<Map<String, dynamic>> mapUsers = [];

  static void seed() {
    _seedUsers();
    _seedMissions();
    _seedTransactions();
    _seedPollutionReports();
    _seedCollections();
    _seedPosts();
  }

  static void _seedUsers() {
    users.add(UserModel(
      id: 'user_self', phone: '+237670000000', name: 'Jordan Mbah',
      role: 'collecteur', balance: 45250, rating: 4.8, completedMissions: 37,
      isOnline: true, latitude: 4.0511, longitude: 9.7679,
      photoUrl: 'https://images.unsplash.com/photo-1769636929354-59165ba73c7e?auto=format&fit=crop&w=200&h=200&q=80',
      collectedTypes: ['Fer/Métal', 'Aluminium', 'Plastique PET', 'Carton'],
    ));

    for (int i = 0; i < 100; i++) {
      final city = _cities[i % _cities.length];
      final name = _names[i % _names.length];
      final role = _roles[i % 3];
      final isOnline = i % 4 != 0;
      users.add(UserModel(
        id: 'user_$i',
        phone: '+2376${70 + (i % 10)}${i.toString().padLeft(6, '0')}',
        name: name,
        uniqueId: '@${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '')}${i + 100}',
        role: role,
        balance: (2000 + i * 1500 + (i % 7) * 800).toDouble(),
        rating: 3.0 + (i % 7) * 0.25,
        completedMissions: 3 + i * 2 + (i % 5),
        isOnline: isOnline,
        latitude: city.$2 + (i % 11 - 5) * 0.04,
        longitude: city.$3 + (i % 11 - 5) * 0.04,
        photoUrl: 'https://images.unsplash.com/photo-${_profilePhotoIds[i % _profilePhotoIds.length]}?auto=format&fit=crop&w=200&h=200&q=80',
        collectedTypes: _collectedTypes[i % _collectedTypes.length],
      ));

      mapUsers.add({
        'id': 'user_$i',
        'latitude': city.$2 + (i % 11 - 5) * 0.04,
        'longitude': city.$3 + (i % 11 - 5) * 0.04,
        'role': role,
        'name': name,
        'photoUrl': 'https://images.unsplash.com/photo-${_profilePhotoIds[i % _profilePhotoIds.length]}?auto=format&fit=crop&w=200&h=200&q=80',
        'isOnline': isOnline,
      });
    }
  }

  static void _seedPosts() {
    final descriptions = [
      'Grande collecte aujourd\'hui! 50kg de plastique PET prêts pour le recyclage ♻️',
      'Merci à l\'entreprise de recyclage pour l\'achat de mes 30kg d\'aluminium!',
      'Nouveau record personnel! 100kg de carton collectés cette semaine 📦',
      'Mission de tri terminée à Yaoundé, 25kg de verre propre 🫙',
      'Première collecte de l\'année! Belle collaboration avec les livreurs 🚛',
      'Fer et métal récupérés sur un chantier de démolition, 200kg! 🏗️',
      'Sensibilisation au recyclage dans le quartier aujourd\'hui 🌍',
      'Ces bouteilles PET vont être transformées en fibres textiles! Incroyable ♻️',
      'Collecte de pneus usagés terminée. Direction l\'usine de recyclage! 🛞',
      'Bravo à toute l\'équipe! 500kg de déchets détournés de la décharge cette semaine',
      'Nouveau lot d\'appareils électroniques à recycler 💻',
      'Carton et papier: 80kg collectés chez un partenaire commercial 📋',
      'Collecte de 150kg de ferraille dans une entreprise à Douala 🏭',
      'Opération nettoyage du quartier Mvan à Yaoundé, 300kg ramassés! 🧹',
      'Transformation de plastique PET en pavés écologiques, projet pilote 🧱',
      'Livraison de 45kg d\'aluminium à l\'usine de recyclage 🚚',
      'Atelier de sensibilisation au tri sélectif dans une école 📚',
      'Partenaire RecycCam: 200kg de carton collectés cette semaine 📦',
      'Ya des dépotoirs sauvages partout à Bonabéri, ça pue sérieux 🤢',
      'Collaboration avec EcoCameroun SA pour la collecte de déchets électroniques ♻️',
      'Mission spéciale: dépollution de la plage de Limbé 🌊',
      'Bilan de la semaine: 1,2 tonnes de déchets collectés dans le Grand Yaoundé! 📊',
      'Installation de nouveaux bacs de tri sélectif à Bafoussam 🗑️',
      'Regardez comment les caniveaux sont bouchés au quartier, il va pleuvoir et ça va inonder! 🌊',
      'Défi inter-quartiers: qui collecte le plus? Résultats ce weekend! 🏆',
      'Nos livreurs ont parcouru 500km cette semaine pour acheminer les déchets 🛣️',
      'Usine à Douala déverse ses déchets chimiques dans le Wouri, c\'est pas possible ça! ☣️',
      'Journée porte ouverte à l\'usine de recyclage de Douala 🏭',
      'Marché de Mokolo: les déchets s\'accumulent, les commerçants sont fatigués 😤',
      'Résultats du mois: 8 tonnes de déchets traités, 1,8T de CO2 évités 🌱',
      'Ya trop de plastique qui traîne au quartier, sensibilisons nos parents!',
      'Décharge sauvage à Bessengué, les enfants jouent dans les ordures 😢',
    ];

    final wasteTags = [
      ['Plastique PET'], ['Aluminium'], ['Carton', 'Papier'],
      ['Verre'], ['Plastique PEHD', 'Plastique PET'],
      ['Fer/Métal'], ['Mixte'], ['Plastique PET'],
      ['Pneu'], ['Mixte'], ['Électronique'], ['Carton', 'Papier'],
      ['Fer/Métal'], ['Mixte'], ['Plastique PET'],
      ['Aluminium'], ['Papier', 'Carton'], ['Carton'],
      ['Plastique', 'Dépotoir'], ['Électronique'], ['Mixte'],
      ['Mixte'], ['Mixte'], ['Caniveaux', 'Plastique'],
      ['Plastique PET', 'Plastique PEHD'], ['Mixte'],
      ['Déchets chimiques', 'Industriel'], ['Mixte'],
      ['Déchets ménagers'], ['Mixte'],
      ['Plastique'], ['Dépotoir'],
    ];

    final commentsPool = [
      'Ah ma soeur, c\'est vraiment beau ça! 🔥',
      'Mon frère continue comme ça! 💪',
      'Wowo! C\'est fort ça!',
      'Où-même je peux participer?',
      'Ah mon gars, tu gères! ♻️',
      'Félicitations à toute l\'équipe!',
      'Je veux faire pareil oh!',
      'Le Cameroun a besoin de plus de gens comme vous!',
      'Super initiative, que Dieu vous bénisse!',
      'Partagez plus de photos, on veut voir!',
      'Combien de temps pour cette collecte?',
      'C\'est génial, vraiment!',
      'Merci pour votre engagement écologique 🌍',
      'Quel quartier exactement?',
      'Je suis dispo pour aider la prochaine fois, comptez sur moi!',
      'Magnifique travail, les gars!',
      'Ensemble, rendons le Cameroun plus propre!',
      'Très fier de vous, ma famille!',
      'Combien de kg au total? Dites-nous!',
      'Vous êtes une vraie inspiration!',
      'J\'aimerais rejoindre le mouvement, qui contacter?',
      'La prochaine mission c\'est quand?',
      'Bravo à toute l\'équipe de RecycPay!',
      'Excellente nouvelle! Le Cameroun avance!',
      'Continuez à sensibiliser autour de vous!',
      'Le recyclage, c\'est vraiment l\'avenir chez nous!',
      'Félicitations! Très beau résultat!',
      'Où est-ce que je peux déposer mes déchets moi?',
      'Je collecte aussi dans mon quartier à Bafoussam!',
      'Superbe collaboration, c\'est comme ça qu\'on va changer les choses!',
      'Ah c\'est pas possible tout ce plastique par terre 😢',
      'Il faut que la mairie fasse quelque chose!',
      'Même les caniveaux sont bouchés, à chaque pluie c\'est l\'inondation!',
      'Qui est responsable de tout ça? C\'est triste oh!',
      'On doit se mobiliser pour nettoyer notre quartier!',
      'Si chacun pouvait jeter ses déchets à la poubelle... 😤',
      'Bravo pour le nettoyage! Il faut continuer!',
      'Le gouvernement doit installer des bacs de collecte partout!',
      'Ah les sacs plastiques là, c\'est vraiment un problème!',
      'Petit à petit on va y arriver, faut pas abandonner!',
    ];

    final imgIds = [
      '1594386479412-fa62932f4cdc',
      '1601979112151-26f9fa4520b5',
      '1554226525-780cbb187456',
      '1620609997104-1cd7ca877232',
      '1662611527385-6499f6bfb9cb',
      '1698052842678-6390a810d713',
      '1745725427797-d0b3e3b7a8af',
      '1715065590103-0eb717ace022',
      '1604325409796-d3543be4020c',
      '1710093072218-0024b8391475',
      '1761986756423-f6e3802e44be',
      '1590701800828-ba719848e79a',
      '1662534264036-7bfa0d35de9c',
      '1774167062621-a3ce0cccfe47',
      '1662611527358-7855c4fe8398',
    ];

    for (int i = 0; i < 80; i++) {
      final user = users[i % users.length];
      final descIndex = i % descriptions.length;
      final postId = 'post_$i';

      final commentCount = 2 + (i % 12);
      final cmts = <CommentModel>[];
      for (int j = 0; j < commentCount; j++) {
        cmts.add(CommentModel(
          id: 'comment_${i}_$j',
          postId: postId,
          userId: users[(i + j * 3) % users.length].id,
          userName: users[(i + j * 3) % users.length].name,
          userPhotoUrl: users[(i + j * 3) % users.length].photoUrl,
          content: commentsPool[(i + j * 7) % commentsPool.length],
        ));
      }
      comments[postId] = cmts;

      posts.add(PostModel(
        id: postId,
        userId: user.id,
        userName: user.name,
        userUniqueId: user.uniqueId,
        userPhotoUrl: user.photoUrl,
        imageUrl: 'https://images.unsplash.com/photo-${imgIds[i % imgIds.length]}?auto=format&fit=crop&w=400&h=300&q=80',
        description: descriptions[descIndex],
        wasteTypes: wasteTags[descIndex],
        likes: 8 + (i * 5 + 7) % 55,
        commentsCount: cmts.length,
        createdAt: DateTime.now().subtract(Duration(hours: i * 2 + (i % 5) * 3, minutes: i * 11 % 60)),
        isLiked: i % 5 == 0,
      ));
    }
  }

  static void _seedMissions() {
    final types = ['collecte', 'livraison', 'tri'];
    final statuses = ['available', 'available', 'available', 'available', 'in_progress', 'completed'];
    final addresses = [
      'Rue 12, Douala', 'Mvan, Yaoundé', 'Centre-ville, Bafoussam',
      'Quartier Plateau, Garoua', 'Domayo, Maroua', 'Nkwen, Bamenda',
      'Cité Sic, Douala', 'Bastos, Yaoundé', 'Marché A, Bafoussam',
      'Camp SIC, Yaoundé', 'Bonabéri, Douala', 'Mokolo, Yaoundé',
      'Quartier Bali, Douala', 'Mendong, Yaoundé', 'Tsinga, Yaoundé',
      'Village, Buea', 'Quartier Fôret, Kribi', 'Zone portuaire, Douala',
      'Rue des artisans, Nkongsamba', 'Plage de Limbé', 'Carrefour, Sangmélima',
      'Marché central, Bertoua', 'Gare routière, Ngaoundéré', 'Quartier Plateau, Bamenda',
      'Rue principale, Ebolowa', 'Zone industrielle, Douala', 'Aéroport, Yaoundé',
      'Quartier Millenium, Yaoundé', 'Bonamoussadi, Douala', 'Makepe, Douala',
    ];

    for (int i = 0; i < 60; i++) {
      final city = _cities[i % _cities.length];
      final type = types[i % 3];
      final status = statuses[i % statuses.length];

      final wasteImgs = [
        'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?auto=format&fit=crop&w=400&h=300&q=80',
        'https://images.unsplash.com/photo-1604187351574-c75ca79f5807?auto=format&fit=crop&w=400&h=300&q=80',
        'https://images.unsplash.com/photo-1542293787938-c9e299b880cc?auto=format&fit=crop&w=400&h=300&q=80',
        'https://images.unsplash.com/photo-1611284446314-60a58ac0deb9?auto=format&fit=crop&w=400&h=300&q=80',
        'https://images.unsplash.com/photo-1578911595541-1e31d7d7c1ed?auto=format&fit=crop&w=400&h=300&q=80',
        'https://images.unsplash.com/photo-1605600659873-2c5c9e8e5b7b?auto=format&fit=crop&w=400&h=300&q=80',
        'https://images.unsplash.com/photo-1529078155058-5d71645b8a02?auto=format&fit=crop&w=400&h=300&q=80',
        'https://images.unsplash.com/photo-1567393528677-d6adae7d4a0a?auto=format&fit=crop&w=400&h=300&q=80',
      ];

      final descriptions = [
        'Bouteilles plastique PET propres et compressées. Poids estimé : 15 kg. À collecter au domicile.',
        'Cartons d\'emballage pliés et ficelés. Environ 25 kg. Prêt pour le recyclage.',
        'Déchets électroniques : vieux téléphones, chargeurs, câbles. À dépolluer avant recyclage.',
        'Ferraille et métaux mélangés (fer, aluminium, cuivre). Poids total estimé : 50 kg.',
        'Huile de friture usagée en bidons de 5L. 20 litres à collecter pour valorisation énergétique.',
        'Pneus usagés (12 unités) à collecter pour recyclage caoutchouc. Stockés sous abri.',
        'Verre mélangé (bouteilles, bocaux) dans bac de collecte. Environ 30 kg.',
        'Déchets verts (feuilles, branchages) issus du jardinage. À composter ou valoriser.',
        'Papiers et magazines en vrac. Poids estimé : 10 kg. À collecter au bureau.',
        'Boîtes de conserve et canettes aluminium lavées et aplaties. 8 kg au total.',
      ];

      final photoCount = 2 + (i % 3); // 2-4 photos per mission
      final imgs = List.generate(photoCount, (j) => wasteImgs[(i + j) % wasteImgs.length]);

      missions.add(MissionModel(
        id: 'mission_$i',
        type: type,
        collectionId: 'collection_${i % 40}',
        collectorId: i % 3 == 0 ? users[i % users.length].id : null,
        collectorName: i % 3 == 0 ? users[i % users.length].name : null,
        delivererId: type == 'livraison' ? users[(i + 5) % users.length].id : null,
        delivererName: type == 'livraison' ? users[(i + 5) % users.length].name : null,
        sorterId: type == 'tri' ? users[(i + 8) % users.length].id : null,
        sorterName: type == 'tri' ? users[(i + 8) % users.length].name : null,
        status: status,
        commission: 300.0 + (i * 180) + (i % 7) * 100,
        distance: 0.5 + (i % 15) * 0.8,
        imageUrls: imgs,
        description: descriptions[i % descriptions.length],
        pickupLatitude: city.$2 + 0.02,
        pickupLongitude: city.$3 + 0.02,
        dropLatitude: city.$2 + 0.08,
        dropLongitude: city.$3 + 0.06,
        pickupAddress: addresses[i % addresses.length],
        dropAddress: 'Centre de recyclage, ${city.$1}',
        createdAt: DateTime.now().subtract(Duration(hours: i * 3 + (i % 4) * 2)),
        acceptedAt: status == 'in_progress' || status == 'completed'
            ? DateTime.now().subtract(Duration(hours: i * 3 + (i % 4) * 2 - 1))
            : null,
        completedAt: status == 'completed'
            ? DateTime.now().subtract(Duration(hours: i * 3 + (i % 4) * 2 - 3))
            : null,
      ));
    }
  }

  static void _seedTransactions() {
    final types = ['deposit', 'payment', 'commission', 'withdrawal', 'bonus'];
    final descriptions = [
      'Collecte plastique PET - 15kg', 'Paiement aluminium 30kg',
      'Commission livraison', 'Retrait Orange Money', 'Bonus fidélité',
      'Collecte carton 25kg', 'Paiement verre 12kg', 'Commission tri',
      'Collecte ferraille 50kg', 'Paiement plastique PEHD 20kg',
      'Bonus performance mensuelle', 'Retrait MTN Mobile Money',
      'Collecte électronique 8kg', 'Paiement pneus usagés',
      'Commission collecte spéciale', 'Bonus parrainage',
      'Collecte bois 40kg', 'Paiement huile usagée 15L',
      'Collecte mixte 35kg', 'Retrait partiel',
      'Prime objectif atteint', 'Collecte aluminium 22kg',
      'Paiement carton 60kg', 'Commission super mission',
      'Bonus écologique trimestriel',
    ];

    final networks = ['Orange Money', 'MTN Mobile Money', 'Orange Money', 'MTN Mobile Money'];

    for (int i = 0; i < 100; i++) {
      final type = types[i % types.length];
      final amount = type == 'withdrawal'
          ? (2000.0 + (i % 15) * 1500)
          : (1000.0 + (i % 20) * 800);
      final netIdx = i % networks.length;
      transactions.add(TransactionModel(
        id: 'txn_$i',
        userId: 'user_self',
        type: type,
        amount: amount,
        commission: type == 'commission' ? amount * 0.1 : null,
        status: i % 8 == 0 ? 'pending' : 'completed',
        reference: 'REF-${DateTime.now().millisecondsSinceEpoch}-$i',
        description: '${descriptions[i % descriptions.length]} ${type == 'withdrawal' ? '· ${networks[netIdx]}' : ''}',
        createdAt: DateTime.now().subtract(Duration(days: i ~/ 3, hours: i * 5 % 24, minutes: i * 17 % 60)),
      ));
    }
  }

  static void _seedPollutionReports() {
    final severities = ['low', 'medium', 'medium', 'high', 'critical'];
    final descriptions = [
      'Dépôt sauvage de plastiques près du marché',
      'Décharge illégale de déchets électroniques',
      'Accumulation d\'ordures ménagères dans la rue',
      'Déversement d\'huile usagée dans le caniveau',
      'Montagne de pneus usés à l\'abandon',
      'Déchets de chantier obstruant l\'égout',
      'Dépôt de ferraille rouillée dangereuse',
      'Pollution au plastique près de la rivière',
      'Déchets hospitaliers abandonnés en pleine rue',
      'Décharge sauvage de batteries usagées',
      'Ruisseau obstrué par des déchets plastiques',
      'Dépôt de gravats sur le trottoir',
      'Odeurs nauséabondes provenant d\'un dépotoir',
      'Déchets verts en décomposition en bord de route',
      'Pollution sonore de l\'usine de traitement',
      'Dépôt de matériel électronique hors d\'usage',
      'Cadavres d\'animaux près du point d\'eau',
      'Déchets toxiques non identifiés',
      'Dépôt clandestin dans une zone résidentielle',
      'Accumulation de déchets après le marché hebdomadaire',
      'Déchets plastiques dans la lagune',
      'Décharge à ciel ouvert près de l\'école',
      'Pollution au mercure dans la zone artisanale',
      'Dépôt de pneus brûlés dégageant une fumée noire',
      'Déchets textiles abandonnés par une usine',
      'Pollution au plomb dans le quartier industriel',
      'Dépôt de ferraille dangereuse pour les enfants',
      'Déchets de poissonnerie en décomposition',
      'Pollution aux hydrocarbures sur la plage',
      'Déchets de construction obstruant la route',
      'Dépotoir sauvage derrière le marché central',
      'Déchets plastiques dans les égouts',
      'Pneus brûlés dans la carrière abandonnée',
      'Déchets agroalimentaires en décomposition',
      'Huile de vidange déversée dans le sol',
      'Déchets de menuiserie (bois traité) abandonnés',
      'Dépôt de vieux vêtements non biodégradables',
      'Accumulation de mégots et plastiques sur la plage',
      'Déchets de chantier naval à Kribi',
      'Pollution lumineuse et déchets électroniques',
      'Dépôt de vieilles batteries de voiture',
      'Déchets de laboratoire non conformes',
      'Montagne d\'ordures au carrefour principal',
      'Déchets plastiques dans les champs agricoles',
      'Pollution au goudron dans la zone industrielle',
      'Dépôt de carcasses de véhicules',
      'Déchets de coiffure (cheveux, produits chimiques)',
      'Dépotoir dans le lit du cours d\'eau',
      'Pollution aux particules fines près de l\'usine',
      'Déchets de démolition amiantés (dangereux)',
    ];

    final addresses = [
      'Marché Central, Douala', 'Quartier Mvan, Yaoundé', 'Rue Principale, Bafoussam',
      'Zone Industrielle, Garoua', 'Domayo Nord, Maroua', 'Nkwen Carrefour, Bamenda',
      'Cité Sic, Douala', 'Bastos, Yaoundé', 'Marché A, Bafoussam',
      'Camp SIC, Yaoundé', 'Bonabéri, Douala', 'Mokolo, Yaoundé',
      'Quartier Bali, Douala', 'Mendong, Yaoundé', 'Riviera, Yaoundé',
      'Village, Buea', 'Plage, Kribi', 'Port, Douala',
      'Route des Artisans, Nkongsamba', 'Limbé Centre', 'Sangmélima Ville',
      'Bertoua Marché', 'Ngaoundéré Gare', 'Bamenda Plateau',
      'Ebolowa Ville', 'Zone Indus, Douala', 'Aéroport, Yaoundé',
      'Carrefour Tropicana', 'Bonamoussadi, Douala', 'Makepe, Douala',
    ];

    for (int i = 0; i < 50; i++) {
      final city = _cities[i % _cities.length];
      pollutionReports.add(PollutionReportModel(
        id: 'report_$i',
        userId: users[i % users.length].id,
        userName: users[i % users.length].name,
        description: descriptions[i % descriptions.length],
        photoUrl: null,
        latitude: city.$2 + (i % 11 - 5) * 0.025,
        longitude: city.$3 + (i % 11 - 5) * 0.025,
        address: addresses[i % addresses.length],
        severity: severities[i % severities.length],
        reportCount: 1 + (i % 12),
        isCritical: i % 6 == 3,
        createdAt: DateTime.now().subtract(Duration(days: i ~/ 2, hours: i * 7 % 24, minutes: i * 13 % 60)),
      ));
    }
  }

  static void _seedCollections() {
    final categories = Constants.wasteCategories;
    final statuses = ['pending', 'pending', 'accepted', 'in_progress', 'completed', 'completed', 'paid', 'cancelled'];
    final descriptions = [
      'Collecte régulière', 'Grand volume', 'Urgent', 'Programmé',
      'Collecte hebdomadaire', 'Nettoyage de site', 'Dépôt direct',
      'Collecte d\'entreprise', 'Ramassage scolaire', 'Opération quartier',
      'Collecte communautaire', 'Dépôt volontaire', 'Collecte d\'urgence',
      'Campagne de nettoyage', 'Collecte spéciale fête',
    ];
    final companies = [
      'RecycCam SARL', 'EcoCameroun SA', 'GreenCycle Ltd', 'Cameroon Recycle',
      'WasteCare Intl', 'EcoSolutions', 'Recyclage Plus', 'CleanCam',
      'Traitement Vert', 'Valorisation SA', 'EcoVal Cameroon', 'GreenFuture Corp',
    ];

    for (int i = 0; i < 40; i++) {
      final cat = categories[i % categories.length];
      final weight = 3.0 + (i * 2.8) + (i % 5) * 1.5;
      final price = Constants.defaultPrices[cat] ?? 150;
      final city = _cities[i % _cities.length];
      final status = statuses[i % statuses.length];
      final isTerminal = status == 'completed' || status == 'paid';
      final actualW = isTerminal ? weight + (i % 7).toDouble() - 2 : null;

      collections.add(WasteCollectionModel(
        id: 'collection_$i',
        userId: users[i % users.length].id,
        userName: users[i % users.length].name,
        category: cat,
        estimatedWeight: weight,
        actualWeight: actualW,
        pricePerKg: price,
        totalAmount: actualW != null ? actualW * price : null,
        status: status,
        photoUrl: i % 3 == 0 ? 'https://images.unsplash.com/photo-1662611527385-6499f6bfb9cb?auto=format&fit=crop&w=200&h=200&q=80' : null,
        description: descriptions[i % descriptions.length],
        latitude: city.$2 + 0.01,
        longitude: city.$3 + 0.01,
        address: 'Quartier ${city.$1}',
        companyId: 'company_${i % 6}',
        companyName: companies[i % companies.length],
        createdAt: DateTime.now().subtract(Duration(days: i * 2 + (i % 3), hours: i * 4 % 24)),
        completedAt: isTerminal
            ? DateTime.now().subtract(Duration(days: i * 2 + (i % 3) - 1))
            : null,
      ));
    }
  }

  static List<LatLng> getUserLocationsByRole(String role) {
    return mapUsers
        .where((u) => u['role'] == role)
        .map((u) => LatLng(u['latitude'] as double, u['longitude'] as double))
        .toList();
  }

  static List<Map<String, dynamic>> getActiveUsers() {
    return mapUsers.toList();
  }
}
