import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/mock_data.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

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
    _user = MockData.users.firstWhere((u) => u.id == 'user_self');
    _isLoggedIn = true;
  }

  Future<void> checkLoginStatus() async {
    _isLoggedIn = await _authService.isLoggedIn();
    if (_isLoggedIn) {
      try {
        _user = await _authService.getProfile();
      } catch (e) {
        _isLoggedIn = false;
      }
    }
    if (!_isLoggedIn && _user == null) {
      _user = MockData.users.firstWhere((u) => u.id == 'user_self');
      _isLoggedIn = true;
    }
    notifyListeners();
  }

  Future<void> sendOtp(String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.sendOtp(phone);
    } catch (e) {
      _error = "Erreur d'envoi du code";
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _authService.verifyOtp(phone, otp);
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Code invalide';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<UserModel?> register({
    required String phone,
    required String name,
    required String role,
    String? photoUrl,
    List<String>? collectedTypes,
    double? latitude,
    double? longitude,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _authService.register(
        phone: phone,
        name: name,
        role: role,
        photoUrl: photoUrl,
        collectedTypes: collectedTypes,
        latitude: latitude,
        longitude: longitude,
      );
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return _user;
    } catch (e) {
      _error = "Erreur d'inscription";
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> updateLocation(double lat, double lng) async {
    try {
      await _authService.updateLocation(lat, lng);
    } catch (_) {}
  }

  Future<void> switchRole(String role) async {
    try {
      await _authService.switchRole(role);
      _user = _authService.currentUser;
      notifyListeners();
    } catch (_) {
      if (_user != null) {
        _user = _user!.copyWith(role: role);
        notifyListeners();
      }
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      await _authService.updateProfile(data);
      _user = _authService.currentUser;
    } catch (e) {
      if (_user != null) {
        _user = _user!.copyWith(
          name: data['name'] as String? ?? _user!.name,
          role: data['role'] as String? ?? _user!.role,
          collectedTypes: data['collected_types'] != null
              ? List<String>.from(data['collected_types'] as List)
              : _user!.collectedTypes,
        );
      }
      _error = 'Erreur de mise à jour';
    }
    notifyListeners();
  }

  void setMockUser(UserModel user) {
    _user = user;
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
