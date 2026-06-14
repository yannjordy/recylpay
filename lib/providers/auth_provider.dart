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
  int _referralCount = 0;
  List<String> _referredUsers = [];

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get error => _error;
  int get referralCount => _referralCount;
  List<String> get referredUsers => _referredUsers;

  AuthProvider() {
    MockData.seed();
  }

  double get totalReferralEarnings => _referralCount * 5;

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('current_email');
    if (email != null && email.isNotEmpty) {
      final usersJson = prefs.getString('registered_users') ?? '{}';
      final users = Map<String, dynamic>.from(jsonDecode(usersJson));
      if (users.containsKey(email)) {
        final data = Map<String, dynamic>.from(users[email]);
        _user = _userFromMap(email, data);
        _loadReferralStats(email);
        _isLoggedIn = true;
      }
    }
    notifyListeners();
  }

  Future<bool> login(
    String email, String password, {
    String? name,
    String? role,
    String? photoUrl,
    String? referralCode,
  }) async {
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
      _loadReferralStats(email);
    } else {
      final id = const Uuid().v4();
      final generated = UserModel.generateReferralCode(name ?? email.split('@').first);
      final newUser = {
        'id': id,
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
        'referral_code': generated,
        'referred_by': null,
        'referral_earnings': 0,
      };
      users[email] = newUser;
      await prefs.setString('registered_users', jsonEncode(users));
      _user = _userFromMap(email, newUser);
      _loadReferralStats(email);

      // Handle referral bonus
      if (referralCode != null && referralCode.trim().isNotEmpty) {
        await _applyReferralBonus(referralCode.trim().toUpperCase(), email, prefs, users);
      }
    }

    await prefs.setString('current_email', email);
    _isLoggedIn = true;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> _applyReferralBonus(
    String code, String newUserEmail, SharedPreferences prefs, Map<String, dynamic> users,
  ) async {
    String? referrerEmail;
    String? referrerKey;
    for (final entry in users.entries) {
      final data = Map<String, dynamic>.from(entry.value);
      if (data['referral_code'] == code) {
        referrerEmail = entry.key;
        referrerKey = entry.key;
        break;
      }
    }
    if (referrerEmail == null) return;

    // Add bonus to referrer
    final refData = Map<String, dynamic>.from(users[referrerKey!]);
    final currentBalance = (refData['balance'] as num?)?.toDouble() ?? 0;
    final currentEarnings = (refData['referral_earnings'] as num?)?.toDouble() ?? 0;
    refData['balance'] = currentBalance + 5;
    refData['referral_earnings'] = currentEarnings + 5;
    users[referrerKey] = refData;

    // Mark new user as referred
    final newData = Map<String, dynamic>.from(users[newUserEmail]);
    newData['referred_by'] = referrerEmail;
    users[newUserEmail] = newData;

    // Track referred users
    final referralList = prefs.getString('referred_by_$referrerKey') ?? '[]';
    final list = List<String>.from(jsonDecode(referralList));
    list.add(newUserEmail);
    await prefs.setString('referred_by_$referrerKey', jsonEncode(list));

    await prefs.setString('registered_users', jsonEncode(users));

    // Refresh current user if they are the referrer
    if (_user?.email == referrerEmail) {
      _user = _userFromMap(referrerEmail, refData);
      _loadReferralStats(referrerEmail);
    }
  }

  void _loadReferralStats(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final referralList = prefs.getString('referred_by_$email');
    if (referralList != null) {
      _referredUsers = List<String>.from(jsonDecode(referralList));
      _referralCount = _referredUsers.length;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? role,
    List<String>? collectedTypes,
    String? photoUrl,
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
    if (photoUrl != null) data['photo_url'] = photoUrl;
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
    _referralCount = 0;
    _referredUsers = [];
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
      referralCode: data['referral_code'] as String?,
      referredBy: data['referred_by'] as String?,
      referralEarnings: (data['referral_earnings'] as num?)?.toDouble() ?? 0,
      points: (data['points'] as num?)?.toInt() ?? 5,
    );
  }

  String get referralLink {
    if (_user?.referralCode == null) return '';
    return 'https://recylpay.com/parrainage?code=${_user!.referralCode}';
  }

  Future<void> addPoints(int amount) async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('current_email');
    if (email == null) return;
    final usersJson = prefs.getString('registered_users') ?? '{}';
    final users = Map<String, dynamic>.from(jsonDecode(usersJson));
    if (!users.containsKey(email)) return;
    final data = Map<String, dynamic>.from(users[email]);
    final current = (data['points'] as num?)?.toInt() ?? 5;
    data['points'] = current + amount;
    users[email] = data;
    await prefs.setString('registered_users', jsonEncode(users));
    _user = _userFromMap(email, data);
    notifyListeners();
  }

  Future<void> completeTaskWithUser(String otherUserEmail, String taskType) async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('current_email');
    if (email == null) return;
    final usersJson = prefs.getString('registered_users') ?? '{}';
    final users = Map<String, dynamic>.from(jsonDecode(usersJson));

    int pointsGained;
    switch (taskType) {
      case 'tri':
        pointsGained = 3;
      case 'ramassage':
        pointsGained = 5;
      case 'livraison':
        pointsGained = 4;
      default:
        pointsGained = 2;
    }

    // Update current user: add points
    final myData = Map<String, dynamic>.from(users[email]);
    myData['points'] = ((myData['points'] as num?)?.toInt() ?? 5) + pointsGained;
    myData['completed_missions'] = ((myData['completed_missions'] as num?)?.toInt() ?? 0) + 1;
    users[email] = myData;

    // Update other user: add points too
    if (users.containsKey(otherUserEmail)) {
      final otherData = Map<String, dynamic>.from(users[otherUserEmail]);
      otherData['completed_missions'] = ((otherData['completed_missions'] as num?)?.toInt() ?? 0) + 1;
      otherData['points'] = ((otherData['points'] as num?)?.toInt() ?? 5) + pointsGained;
      users[otherUserEmail] = otherData;
    }

    await prefs.setString('registered_users', jsonEncode(users));
    _user = _userFromMap(email, myData);
    notifyListeners();
  }
}
