import 'package:flutter/material.dart';
import '../models/mission_model.dart';
import '../services/mock_data.dart';

class MissionProvider extends ChangeNotifier {
  List<MissionModel> _missions = [];
  bool _isLoading = false;
  String? _error;

  List<MissionModel> get missions => _missions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  MissionProvider() {
    _missions = List.from(MockData.missions);
  }

  Future<void> loadMissions({String? type, String? status}) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _missions = List.from(MockData.missions);
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  Future<void> acceptMission(String id) async {
    final index = _missions.indexWhere((m) => m.id == id);
    if (index != -1) {
      _missions[index] = _missions[index].copyWith(
        status: 'accepted',
        acceptedAt: DateTime.now(),
      );
    }
    notifyListeners();
  }

  Future<void> completeMission(String id) async {
    final index = _missions.indexWhere((m) => m.id == id);
    if (index != -1) {
      _missions[index] = _missions[index].copyWith(
        status: 'completed',
        completedAt: DateTime.now(),
      );
    }
    notifyListeners();
  }
}
