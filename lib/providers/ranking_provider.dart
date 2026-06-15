import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RankedUser {
  final String email;
  final String name;
  final String? photoUrl;
  final int points;
  final int rank;

  RankedUser({
    required this.email,
    required this.name,
    this.photoUrl,
    required this.points,
    required this.rank,
  });
}

class RankingProvider extends ChangeNotifier {
  Map<String, Map<String, int>> _bids = {};
  Map<String, Map<String, dynamic>> _users = {};
  String? _error;
  bool _isLoading = false;

  static const _categories = ['trieur', 'ramasseur', 'livreur'];

  String? get error => _error;
  bool get isLoading => _isLoading;
  List<String> get categories => _categories;

  Future<void> loadBids() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('ranking_bids');
    if (raw != null && raw.isNotEmpty) {
      _bids = Map<String, Map<String, int>>.from(
        (jsonDecode(raw) as Map).map((k, v) => MapEntry(
              k as String,
              Map<String, int>.from((v as Map).map((ek, ev) => MapEntry(ek as String, (ev as num).toInt()))),
            )),
      );
    }

    // Load user details
    final usersJson = prefs.getString('registered_users') ?? '{}';
    final allUsers = Map<String, dynamic>.from(jsonDecode(usersJson));
    _users = allUsers.map((k, v) => MapEntry(k, Map<String, dynamic>.from(v as Map)));

    notifyListeners();
  }

  Future<bool> placeBid(String category, int points, String email, String name, String? photoUrl) async {
    if (!_categories.contains(category)) return false;
    if (points <= 0) {
      _error = 'Le nombre de points doit être supérieur à 0';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      final usersJson = prefs.getString('registered_users') ?? '{}';
      final users = Map<String, dynamic>.from(jsonDecode(usersJson));

      if (!users.containsKey(email)) {
        _error = 'Utilisateur introuvable';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final userData = Map<String, dynamic>.from(users[email]);
      final currentPoints = (userData['points'] as num?)?.toInt() ?? 0;

      if (currentPoints < points) {
        _error = 'Tu n\'as que $currentPoints points. Impossible d\'enchérir $points points.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check minimum bid to beat current #1
      final currentBids = _bids[category] ?? {};
      int topBid = 0;
      String? topEmail;
      for (final entry in currentBids.entries) {
        if (entry.value > topBid) {
          topBid = entry.value;
          topEmail = entry.key;
        }
      }

      if (topEmail != null && topEmail != email && points <= topBid) {
        _error = 'Le leader a $topBid points. Enchéris au moins ${topBid + 1} points pour prendre la tête.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Deduct points
      userData['points'] = currentPoints - points;
      users[email] = userData;
      await prefs.setString('registered_users', jsonEncode(users));

      // Save bid (cumulative)
      _bids[category] ??= {};
      _bids[category]![email] = (_bids[category]![email] ?? 0) + points;
      await prefs.setString('ranking_bids', jsonEncode(_bids));

      // Update local cache
      _users[email] = Map<String, dynamic>.from(userData);

      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  List<RankedUser> getRankedUsers(String category) {
    final currentBids = _bids[category] ?? {};
    if (currentBids.isEmpty) return [];

    final sorted = currentBids.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final result = <RankedUser>[];
    int rank = 1;

    for (int i = 0; i < sorted.length; i++) {
      final userData = _users[sorted[i].key];
      result.add(RankedUser(
        email: sorted[i].key,
        name: userData?['name'] as String? ?? sorted[i].key.split('@').first,
        photoUrl: userData?['photo_url'] as String?,
        points: sorted[i].value,
        rank: rank,
      ));
      if (i + 1 < sorted.length && sorted[i + 1].value < sorted[i].value) {
        rank = i + 2;
      }
    }

    return result;
  }

  int getPointsToBeat(String category) {
    final currentBids = _bids[category] ?? {};
    int topBid = 0;
    for (final entry in currentBids.entries) {
      if (entry.value > topBid) topBid = entry.value;
    }
    return topBid;
  }

  int getUserBid(String category, String email) {
    return _bids[category]?[email] ?? 0;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
