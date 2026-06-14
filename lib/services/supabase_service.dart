import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._();
  SupabaseService._();
  factory SupabaseService() => _instance;

  SupabaseClient get client => Supabase.instance.client;

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
}
