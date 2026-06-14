import '../models/waste_collection_model.dart';
import 'api_service.dart';

class CollectionService {
  final ApiService _api = ApiService();

  Future<List<WasteCollectionModel>> getCollections({String? status}) async {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;
    final response = await _api.get('/collections', params: params);
    final data = response.data as List;
    return data.map((e) => WasteCollectionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<WasteCollectionModel> getCollection(String id) async {
    final response = await _api.get('/collections/$id');
    return WasteCollectionModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<WasteCollectionModel> createCollection(WasteCollectionModel collection) async {
    final response = await _api.post('/collections', data: collection.toJson());
    return WasteCollectionModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<WasteCollectionModel> updateCollection(String id, Map<String, dynamic> data) async {
    final response = await _api.put('/collections/$id', data: data);
    return WasteCollectionModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> validateWeight(String id, double weight) async {
    await _api.put('/collections/$id/weight', data: {'actual_weight': weight});
  }

  Future<void> cancelCollection(String id) async {
    await _api.put('/collections/$id/status', data: {'status': 'cancelled'});
  }
}
