import 'package:flutter/material.dart';
import '../models/chat_message_model.dart';
import '../services/ai_service.dart';

class AiProvider extends ChangeNotifier {
  final AiService _service = AiService();

  List<ChatMessageModel> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<ChatMessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> sendMessage(String content) async {
    _messages.add(ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: content,
    ));
    _isLoading = true;
    notifyListeners();

    final response = await _service.chat(
      _messages,
      context: 'Application RecycPay - Gestion des déchets',
    );

    _messages.add(ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'assistant',
      content: response,
    ));
    _isLoading = false;
    notifyListeners();
  }

  Future<String> analyzePollution(String description) async {
    return await _service.analyzePollution(description);
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}
