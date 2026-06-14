class ChatService {
  static final ChatService _instance = ChatService._();
  factory ChatService() => _instance;
  ChatService._();

  final List<ChatConversation> _conversations = [];
  List<ChatConversation> get conversations => List.unmodifiable(_conversations);

  ChatConversation getOrCreateConversation(String userId, String userName, String? photoUrl) {
    final existing = _conversations.cast<ChatConversation?>().firstWhere(
      (c) => c!.otherUserId == userId,
      orElse: () => null,
    );
    if (existing != null) return existing;
    final conv = ChatConversation(
      id: 'conv_$userId',
      otherUserId: userId,
      otherUserName: userName,
      otherUserPhotoUrl: photoUrl,
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
    );
    _conversations.insert(0, conv);
    return conv;
  }

  void seedConversations() {
    final conv1 = ChatConversation(
      id: 'conv_1',
      otherUserId: 'user_3',
      otherUserName: 'Sarah Tchinda',
      otherUserPhotoUrl: 'https://api.dicebear.com/9.x/avataaars/svg?seed=Sarah',
      lastMessage: 'Merci pour la collecte! À demain 👍',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 30)),
      unreadCount: 2,
    );
    conv1.messages.addAll([
      ChatMessage(msgId: 'm1', senderId: 'user_3', text: 'Bonjour! J\'ai du plastique PET à collecter', time: DateTime.now().subtract(const Duration(hours: 2))),
      ChatMessage(msgId: 'm2', senderId: 'user_self', text: 'Parfait! Je peux passer demain matin', time: DateTime.now().subtract(const Duration(hours: 1, minutes: 50))),
      ChatMessage(msgId: 'm3', senderId: 'user_3', text: 'Super, j\'ai environ 30kg', time: DateTime.now().subtract(const Duration(hours: 1, minutes: 40))),
      ChatMessage(msgId: 'm4', senderId: 'user_3', text: 'Merci pour la collecte! À demain 👍', time: DateTime.now().subtract(const Duration(minutes: 30))),
    ]);

    final conv2 = ChatConversation(
      id: 'conv_2',
      otherUserId: 'user_7',
      otherUserName: 'Patrick Essomba',
      otherUserPhotoUrl: 'https://api.dicebear.com/9.x/avataaars/svg?seed=Patrick',
      lastMessage: 'OK je confirme le rdv 14h',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 5)),
      unreadCount: 0,
    );
    conv2.messages.addAll([
      ChatMessage(msgId: 'm5', senderId: 'user_self', text: 'Salut Patrick, dispo pour une livraison?', time: DateTime.now().subtract(const Duration(hours: 6))),
      ChatMessage(msgId: 'm6', senderId: 'user_7', text: 'Oui, je suis libre cet après-midi', time: DateTime.now().subtract(const Duration(hours: 5, minutes: 30))),
      ChatMessage(msgId: 'm7', senderId: 'user_self', text: 'Parfait, rendons-nous au dépôt à 14h', time: DateTime.now().subtract(const Duration(hours: 5, minutes: 15))),
      ChatMessage(msgId: 'm8', senderId: 'user_7', text: 'OK je confirme le rdv 14h', time: DateTime.now().subtract(const Duration(hours: 5))),
    ]);

    final conv3 = ChatConversation(
      id: 'conv_3',
      otherUserId: 'user_1',
      otherUserName: 'Marie-Claire Ngo',
      otherUserPhotoUrl: 'https://api.dicebear.com/9.x/avataaars/svg?seed=Marie',
      lastMessage: 'Très bien, à la prochaine!',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
    );
    conv3.messages.addAll([
      ChatMessage(msgId: 'm9', senderId: 'user_1', text: 'Bonjour, vous collectez le verre?', time: DateTime.now().subtract(const Duration(days: 2))),
      ChatMessage(msgId: 'm10', senderId: 'user_self', text: 'Oui bien sûr! Combien de kg?', time: DateTime.now().subtract(const Duration(days: 2))),
      ChatMessage(msgId: 'm11', senderId: 'user_1', text: 'Environ 15kg de bouteilles', time: DateTime.now().subtract(const Duration(days: 1, hours: 12))),
      ChatMessage(msgId: 'm12', senderId: 'user_self', text: 'Très bien, à la prochaine!', time: DateTime.now().subtract(const Duration(days: 1))),
    ]);

    _conversations.addAll([conv1, conv2, conv3]);
  }

  void sendMessage(String convId, String text) {
    final conv = _conversations.firstWhere((c) => c.id == convId);
    conv.messages.add(ChatMessage(
      msgId: 'm_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'user_self',
      text: text,
      time: DateTime.now(),
    ));
    conv.lastMessage = text;
    conv.lastMessageTime = DateTime.now();
  }
}

class ChatConversation {
  final String id;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserPhotoUrl;
  String lastMessage;
  DateTime lastMessageTime;
  int unreadCount;
  final List<ChatMessage> messages = [];

  ChatConversation({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPhotoUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });
}

class ChatMessage {
  final String msgId;
  final String senderId;
  final String text;
  final DateTime time;

  ChatMessage({
    required this.msgId,
    required this.senderId,
    required this.text,
    required this.time,
  });

  bool get isMine => senderId == 'user_self';
}
