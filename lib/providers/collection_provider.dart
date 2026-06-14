import 'package:flutter/material.dart';
import '../models/waste_collection_model.dart';
import '../services/mock_data.dart';

class CollectionProvider extends ChangeNotifier {
  List<WasteCollectionModel> _collections = [];
  bool _isLoading = false;
  String? _error;

  List<WasteCollectionModel> get collections => _collections;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CollectionProvider() {
    _collections = List.from(MockData.collections);
  }

  Future<void> loadCollections({String? status}) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _collections = List.from(MockData.collections);
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  Future<WasteCollectionModel?> createCollection(WasteCollectionModel collection) async {
    _collections.insert(0, collection);
    MockData.collections.insert(0, collection);
    notifyListeners();
    return collection;
  }

  Future<void> validateWeight(String id, double weight) async {
    final index = _collections.indexWhere((c) => c.id == id);
    if (index != -1) {
      _collections[index] = _collections[index].copyWith(actualWeight: weight, status: 'validated');
      notifyListeners();
    }
  }

  Future<void> cancelCollection(String id) async {
    final index = _collections.indexWhere((c) => c.id == id);
    if (index != -1) {
      _collections[index] = _collections[index].copyWith(status: 'cancelled');
      notifyListeners();
    }
  }
}
