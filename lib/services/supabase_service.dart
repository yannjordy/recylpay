import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._();
  SupabaseService._();
  factory SupabaseService() => _instance;

  SupabaseClient get client => Supabase.instance.client;

  bool get isInitialized {
    try {
      Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> init(String url, String anonKey) async {
    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  // Profiles
  Future<Map<String, dynamic>?> getProfile(String id) async {
    return client.from('profiles').select().eq('id', id).maybeSingle();
  }

  Future<void> upsertProfile(Map<String, dynamic> data) async {
    await client.from('profiles').upsert(data);
  }

  // Transactions
  Future<List<Map<String, dynamic>>> getTransactions(String userId) async {
    final res = await client.from('transactions').select().eq('user_id', userId).order('created_at', ascending: false);
    return res;
  }

  // Posts
  Future<List<Map<String, dynamic>>> getPosts() async {
    final res = await client.from('posts').select('*, profiles(name, photo_url)').order('created_at', ascending: false);
    return res;
  }

  // Companies
  Future<List<Map<String, dynamic>>> getCompanies() async {
    return client.from('companies').select();
  }

  // Notifications
  Future<List<Map<String, dynamic>>> getNotifications(String userId) async {
    return client.from('notifications').select().eq('user_id', userId).order('created_at', ascending: false);
  }

  Future<void> markNotificationRead(String id) async {
    await client.from('notifications').update({'is_read': true}).eq('id', id);
  }

  Future<void> markAllNotificationsRead(String userId) async {
    await client.from('notifications').update({'is_read': true}).eq('user_id', userId).filter('is_read', 'eq', false);
  }

  RealtimeChannel listenNotifications(String userId, void Function(Map<String, dynamic> payload) onInsert) {
    return client
        .channel('notifications:user_id=eq.$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          table: 'notifications',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'user_id', value: userId),
          callback: (payload) => onInsert(payload.newRecord),
        )
        .subscribe();
  }

  // Chat / Conversations
  Future<List<Map<String, dynamic>>> getConversations(String userId) async {
    return client
        .from('conversations')
        .select('*, profiles!conversations_participant_one_fkey(name, photo_url), profiles!conversations_participant_two_fkey(name, photo_url)')
        .or('participant_one.eq.$userId,participant_two.eq.$userId')
        .order('last_message_time', ascending: false);
  }

  Future<List<Map<String, dynamic>>> getMessages(String conversationId) async {
    return client.from('messages').select().eq('conversation_id', conversationId).order('created_at', ascending: true);
  }

  Future<void> sendMessage(String conversationId, String senderId, String text) async {
    await client.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': senderId,
      'text': text,
    });
    await client.from('conversations').update({
      'last_message': text,
      'last_message_time': DateTime.now().toIso8601String(),
    }).eq('id', conversationId);
  }

  Future<String?> createConversation(String userOne, String userTwo) async {
    final existing = await client
        .from('conversations')
        .select()
        .or('and(participant_one.eq.$userOne,participant_two.eq.$userTwo),and(participant_one.eq.$userTwo,participant_two.eq.$userOne)')
        .maybeSingle();
    if (existing != null) return existing['id'] as String;

    final res = await client.from('conversations').insert({
      'participant_one': userOne,
      'participant_two': userTwo,
    }).select();

    if (res.isNotEmpty) return res.first['id'] as String;
    return null;
  }

  RealtimeChannel listenMessages(String conversationId, void Function(Map<String, dynamic> payload) onInsert) {
    return client
        .channel('messages:conversation_id=eq.$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          table: 'messages',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'conversation_id', value: conversationId),
          callback: (payload) => onInsert(payload.newRecord),
        )
        .subscribe();
  }

  // Recycling Tips
  Future<List<Map<String, dynamic>>> getRecyclingTips() async {
    return client.from('recycling_tips').select().order('order_index');
  }
}
