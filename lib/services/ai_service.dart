import 'package:dio/dio.dart';
import '../models/chat_message_model.dart';
import '../utils/constants.dart';

class AiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://openrouter.ai/api/v1',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${Constants.openRouterKey}',
      'HTTP-Referer': Constants.baseUrl,
    },
  ));

  Future<String> chat(List<ChatMessageModel> messages, {String? context}) async {
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
      final response = await _dio.post('/chat/completions', data: {
        'model': 'mistralai/mistral-7b-instruct',
        'messages': msgs,
        'max_tokens': 500,
      });
      return response.data['choices'][0]['message']['content'] as String;
    } catch (e) {
      return "Désolé, je rencontre des difficultés. Veuillez réessayer.";
    }
  }

  Future<String> analyzePollution(String description) async {
    try {
      final response = await _dio.post('/chat/completions', data: {
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
    try {
      final response = await _dio.post('/chat/completions', data: {
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
    try {
      final response = await _dio.post('/chat/completions', data: {
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
}
