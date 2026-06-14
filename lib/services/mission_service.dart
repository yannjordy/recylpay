import '../models/mission_model.dart';
import 'api_service.dart';

class MissionService {
  final ApiService _api = ApiService();

  Future<List<MissionModel>> getMissions({String? type, String? status}) async {
    final params = <String, dynamic>{};
    if (type != null) params['type'] = type;
    if (status != null) params['status'] = status;
    final response = await _api.get('/missions', params: params);
    final data = response.data as List;
    return data.map((e) => MissionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<MissionModel> getMission(String id) async {
    final response = await _api.get('/missions/$id');
    return MissionModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<MissionModel> acceptMission(String id) async {
    final response = await _api.put('/missions/$id/accept');
    return MissionModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<MissionModel> startMission(String id) async {
    final response = await _api.put('/missions/$id/start');
    return MissionModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<MissionModel> completeMission(String id) async {
    final response = await _api.put('/missions/$id/complete');
    return MissionModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> cancelMission(String id) async {
    await _api.put('/missions/$id/cancel');
  }
}
