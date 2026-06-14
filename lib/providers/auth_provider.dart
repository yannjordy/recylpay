import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../services/mock_data.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get error => _error;

  AuthProvider() {
    MockData.seed();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('current_email');
    if (email != null && email.isNotEmpty) {
      final usersJson = prefs.getString('registered_users') ?? '{}';
      final users = Map<String, dynamic>.from(jsonDecode(usersJson));
      if (users.containsKey(email)) {
        final data = Map<String, dynamic>.from(users[email]);
        _user = UserModel(
          id: data['id'] as String,
          phone: data['phone'] as String? ?? '+237690000000',
          name: data['name'] as String? ?? email.split('@').first,
          uniqueId: data['unique_id'] as String? ?? '@${email.split('@').first}',
          role: data['role'] as String? ?? 'collecteur',
          balance: (data['balance'] as num?)?.toDouble() ?? 25000,
          rating: (data['rating'] as num?)?.toDouble() ?? 4.5,
          completedMissions: (data['completed_missions'] as num?)?.toInt() ?? 0,
          isOnline: true,
          latitude: (data['latitude'] as num?)?.toDouble() ?? 4.0511,
          longitude: (data['longitude'] as num?)?.toDouble() ?? 9.7679,
          photoUrl: data['photo_url'] as String?,
          collectedTypes: data['collected_types'] != null ? List<String>.from(data['collected_types']) : ['Tout'],
        );
        _isLoggedIn = true;
      }
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password, {String? name, String? role, String? photoUrl}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    if (email.isEmpty || !email.contains('@')) {
      _error = 'Email invalide';
      _isLoading = false;
      notifyListeners();
      return false;
    }
    if (password.isEmpty || password.length < 3) {
      _error = 'Mot de passe trop court (min 3 caractères)';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('registered_users') ?? '{}';
    final users = Map<String, dynamic>.from(jsonDecode(usersJson));

    if (users.containsKey(email)) {
      final data = Map<String, dynamic>.from(users[email]);
      if (data['password'] != password) {
        _error = 'Mot de passe incorrect';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      _user = _userFromMap(email, data);
    } else {
      // Nouvel utilisateur
      final newUser = {
        'id': const Uuid().v4(),
        'email': email,
        'password': password,
        'name': name ?? email.split('@').first,
        'phone': '+237690000000',
        'unique_id': '@${(name ?? email.split('@').first).toLowerCase().replaceAll(' ', '_')}',
        'role': role ?? 'trieur',
        'balance': 25000,
        'rating': 4.5,
        'completed_missions': 0,
        'latitude': 4.0511,
        'longitude': 9.7679,
        'photo_url': photoUrl,
        'collected_types': ['Tout'],
      };
      users[email] = newUser;
      await prefs.setString('registered_users', jsonEncode(users));
      _user = _userFromMap(email, newUser);
    }

    await prefs.setString('current_email', email);
    _isLoggedIn = true;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> updateProfile({
    String? name,
    String? role,
    List<String>? collectedTypes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('current_email');
    if (email == null) return;
    final usersJson = prefs.getString('registered_users') ?? '{}';
    final users = Map<String, dynamic>.from(jsonDecode(usersJson));
    if (!users.containsKey(email)) return;
    final data = Map<String, dynamic>.from(users[email]);
    if (name != null) data['name'] = name;
    if (role != null) data['role'] = role;
    if (collectedTypes != null) data['collected_types'] = collectedTypes;
    users[email] = data;
    await prefs.setString('registered_users', jsonEncode(users));
    _user = _userFromMap(email, data);
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_email');
    await prefs.remove('landing_seen');
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  UserModel _userFromMap(String email, Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] as String,
      phone: data['phone'] as String? ?? '+237690000000',
      name: data['name'] as String? ?? email.split('@').first,
      uniqueId: data['unique_id'] as String? ?? '@${email.split('@').first}',
      role: data['role'] as String? ?? 'collecteur',
      balance: (data['balance'] as num?)?.toDouble() ?? 25000,
      rating: (data['rating'] as num?)?.toDouble() ?? 4.5,
      completedMissions: (data['completed_missions'] as num?)?.toInt() ?? 0,
      isOnline: true,
      latitude: (data['latitude'] as num?)?.toDouble() ?? 4.0511,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 9.7679,
      photoUrl: data['photo_url'] as String?,
      collectedTypes: data['collected_types'] != null ? List<String>.from(data['collected_types']) : ['Tout'],
    );
  }

  void setMockUser(UserModel user) {
    _user = user;
    _isLoggedIn = true;
    notifyListeners();
  }
}
