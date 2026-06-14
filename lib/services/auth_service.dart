import '../models/user_model.dart';
import '../services/mock_data.dart';
import '../services/secure_storage.dart';

class AuthService {
  final SecureStorage _storage = SecureStorage();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  Future<bool> isLoggedIn() async {
    final stored = await _storage.read(key: 'auth_token');
    return stored != null;
  }

  Future<void> sendOtp(String phone) async {}

  Future<UserModel> verifyOtp(String phone, String otp) async {
    _currentUser = MockData.users.firstWhere((u) => u.phone == phone,
        orElse: () => MockData.users.first);
    await _storage.write(key: 'auth_token', value: 'mock_token_${_currentUser!.id}');
    return _currentUser!;
  }

  Future<UserModel> register({
    required String phone,
    required String name,
    required String role,
    String? photoUrl,
    List<String>? collectedTypes,
    double? latitude,
    double? longitude,
  }) async {
    _currentUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      phone: phone,
      name: name,
      role: role,
      photoUrl: photoUrl,
      collectedTypes: collectedTypes ?? [],
      latitude: latitude ?? 4.0511,
      longitude: longitude ?? 9.7679,
    );
    await _storage.write(key: 'auth_token', value: 'mock_token_${_currentUser!.id}');
    return _currentUser!;
  }

  Future<UserModel> getProfile() async {
    _currentUser = MockData.users.firstWhere((u) => u.id == 'user_self');
    return _currentUser!;
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {}

  Future<void> updateLocation(double lat, double lng) async {}

  Future<void> switchRole(String role) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(role: role);
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    _currentUser = null;
  }
}
