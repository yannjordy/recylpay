import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/pollution_report_model.dart';
import '../services/mock_data.dart';

class MapProvider extends ChangeNotifier {
  LatLng? _currentPosition;
  List<PollutionReportModel> _reports = [];
  List<Map<String, dynamic>> _collecteurs = [];
  List<Map<String, dynamic>> _trieurs = [];
  List<Map<String, dynamic>> _livreurs = [];
  List<Map<String, dynamic>> _activeUsers = [];
  bool _isLoading = false;
  String? _error;
  bool _isTracking = false;

  LatLng? get currentPosition => _currentPosition;
  List<PollutionReportModel> get reports => _reports;
  List<Map<String, dynamic>> get collecteurs => _collecteurs;
  List<Map<String, dynamic>> get trieurs => _trieurs;
  List<Map<String, dynamic>> get livreurs => _livreurs;
  List<Map<String, dynamic>> get activeUsers => _activeUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isTracking => _isTracking;

  MapProvider() {
    _reports = List.from(MockData.pollutionReports);
    _activeUsers = MockData.getActiveUsers();
    for (final u in _activeUsers) {
      final role = u['role'] as String;
      if (role == 'collecteur') _collecteurs.add(u);
      else if (role == 'trieur') _trieurs.add(u);
      else if (role == 'livreur') _livreurs.add(u);
    }
    _currentPosition = const LatLng(4.0511, 9.7679);
  }

  Map<String, dynamic>? findUserAt(LatLng pos) {
    for (final u in _activeUsers) {
      final lat = u['latitude'] as double;
      final lng = u['longitude'] as double;
      if ((lat - pos.latitude).abs() < 0.001 && (lng - pos.longitude).abs() < 0.001) {
        return u;
      }
    }
    return null;
  }

  Future<void> getCurrentLocation() async {
    _currentPosition ??= const LatLng(4.0511, 9.7679);
    notifyListeners();
  }

  void startTracking() {
    _isTracking = true;
  }

  void stopTracking() {
    _isTracking = false;
    notifyListeners();
  }

  Future<void> loadPollutionReports() async {
    _reports = List.from(MockData.pollutionReports);
    notifyListeners();
  }

  Future<void> reportPollution(PollutionReportModel report) async {
    MockData.pollutionReports.add(report);
    _reports = List.from(MockData.pollutionReports);
    notifyListeners();
  }

  Future<void> loadNearbyMissions(double lat, double lng) async {
    await Future.delayed(const Duration(milliseconds: 200));
    notifyListeners();
  }
}
