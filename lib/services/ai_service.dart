import 'dart:math';
import 'package:dio/dio.dart';
import '../models/chat_message_model.dart';
import '../utils/constants.dart';

class AiService {
  final Dio? _dio;
  final bool _enabled;

  AiService()
      : _enabled = Constants.openRouterKey.isNotEmpty,
        _dio = Constants.openRouterKey.isNotEmpty
            ? Dio(BaseOptions(
                baseUrl: 'https://openrouter.ai/api/v1',
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer ${Constants.openRouterKey}',
                  'HTTP-Referer': Constants.baseUrl,
                },
              ))
            : null;

  final _localResponses = [
    "Pour bien trier vos déchets, séparez toujours le plastique, le verre, le métal et le carton. Chaque matière a son circuit de recyclage!",
    "Saviez-vous qu'au Cameroun, seulement 10% des déchets sont recyclés? Vous pouvez faire la différence!",
    "Le PET (plastique) se recycle en fibres textiles. Gardez vos bouteilles propres et sèches!",
    "L'aluminium peut être recyclé indéfiniment sans perdre sa qualité. C'est le matériau le plus rentable!",
    "Pour collecter efficacement, organisez vos tournées par quartier. Groupez les demandes pour optimiser vos déplacements.",
    "Le carton se recycle facilement. Un carton propre et sec vaut plus cher qu'un carton sale!",
    "Les déchets électroniques contiennent des métaux précieux (or, cuivre). Ne les jetez surtout pas!",
    "Vous pouvez gagner jusqu'à 500 FCFA/kg d'aluminium. C'est le matériau le mieux payé!",
    "Pensez à vérifier les prix du marché chaque semaine avant de vendre vos matériaux.",
    "Le verre met 4000 ans à se décomposer. Recycler le verre, c'est protéger notre planète!",
    "Pour une livraison réussie, communiquez toujours votre position exacte au collecteur.",
    "Les pneus usagés peuvent être transformés en pavés écologiques pour nos routes!",
  ];

  Future<String> chat(List<ChatMessageModel> messages, {String? context}) async {
    if (!_enabled) return _localResponse();

    final msgs = messages.map((m) => {
      'role': m.role,
      'content': m.content,
    }).toList();

    if (context != null) {
      msgs.insert(0, {
        'role': 'system',
        'content': 'Tu es RecycBot, assistant intelligent de RecycPay. '
            'Tu aides les utilisateurs avec la gestion des déchets, '
            'le recyclage, et l\'utilisation de la plateforme. '
            'Contexte: $context',
      });
    }

    try {
      final response = await _dio!.post('/chat/completions', data: {
        'model': 'mistralai/mistral-7b-instruct',
        'messages': msgs,
        'max_tokens': 500,
      });
      return response.data['choices'][0]['message']['content'] as String;
    } catch (e) {
      return _localResponse();
    }
  }

  Future<String> analyzePollution(String description) async {
    if (!_enabled) {
      final severities = ['faible', 'moyen', 'élevé', 'critique'];
      final level = severities[Random().nextInt(severities.length)];
      return "Niveau de sévérité estimé: $level.\n"
          "Recommandations: Signalez ce problème aux autorités locales et "
          "partagez la localisation précise. Évitez tout contact direct "
          "avec les déchets dangereux.";
    }

    try {
      final response = await _dio!.post('/chat/completions', data: {
        'model': 'mistralai/mistral-7b-instruct',
        'messages': [
          {
            'role': 'system',
            'content': 'Tu es un analyste environnemental. Analyse ce signalement '
                'de pollution et donne un niveau de sévérité (faible/moyen/élevé/critique) '
                'et des recommandations.',
          },
          {'role': 'user', 'content': description},
        ],
        'max_tokens': 300,
      });
      return response.data['choices'][0]['message']['content'] as String;
    } catch (e) {
      return "Analyse non disponible pour le moment.";
    }
  }

  Future<String> generateReport(String data) async {
    if (!_enabled) {
      return "Rapport environnemental:\n"
          "- Total collecté: Données non disponibles\n"
          "- CO2 évité: Calcul en cours\n"
          "- Recyclage: Actif\n\n"
          "Connectez l'IA (clé API OpenRouter) pour des rapports détaillés.";
    }

    try {
      final response = await _dio!.post('/chat/completions', data: {
        'model': 'mistralai/mistral-7b-instruct',
        'messages': [
          {
            'role': 'system',
            'content': 'Tu génères des rapports environnementaux clairs et concis '
                'à partir de données de collecte de déchets.',
          },
          {'role': 'user', 'content': data},
        ],
        'max_tokens': 500,
      });
      return response.data['choices'][0]['message']['content'] as String;
    } catch (e) {
      return "Génération de rapport indisponible.";
    }
  }

  Future<String> suggestOptimization(String context) async {
    if (!_enabled) {
      return "Optimisations suggérées:\n"
          "1. Planifiez vos collectes tôt le matin\n"
          "2. Regroupez les demandes par quartier\n"
          "3. Utilisez des sacs de différentes couleurs pour le tri\n"
          "4. Pesez vos matériaux avant le départ";
    }

    try {
      final response = await _dio!.post('/chat/completions', data: {
        'model': 'mistralai/mistral-7b-instruct',
        'messages': [
          {
            'role': 'system',
            'content': 'Tu es un expert en optimisation logistique. '
                'Suggère des améliorations pour la collecte et le recyclage des déchets.',
          },
          {'role': 'user', 'content': context},
        ],
        'max_tokens': 300,
      });
      return response.data['choices'][0]['message']['content'] as String;
    } catch (e) {
      return "Suggestions non disponibles.";
    }
  }

  String _localResponse() {
    return _localResponses[Random().nextInt(_localResponses.length)];
  }
}
