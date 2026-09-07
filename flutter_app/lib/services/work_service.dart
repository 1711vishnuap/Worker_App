// lib/services/work_service.dart
// Customer-side operations on the `works` resource.

import '../config/api_constants.dart';
import '../models/category_model.dart';
import '../models/work_model.dart';
import 'api_service.dart';

class WorkService {
  final ApiService _api = ApiService();

  Future<List<CategoryModel>> getCategories() async {
    final data = await _api.get(ApiConstants.categories);
    return (data as List).map((e) => CategoryModel.fromJson(e)).toList();
  }

  Future<WorkModel> createWork({
    required int categoryId,
    required String title,
    String? description,
    String? photoUrl,
    required double lat,
    required double lng,
  }) async {
    final data = await _api.post(ApiConstants.works, body: {
      'category_id': categoryId,
      'title': title,
      'description': description,
      'photo_url': photoUrl,
      'lat': lat,
      'lng': lng,
    });
    return WorkModel.fromJson(data);
  }

  Future<List<WorkModel>> getMyWorks() async {
    final data = await _api.get(ApiConstants.myWorks);
    return (data as List).map((e) => WorkModel.fromJson(e)).toList();
  }

  Future<WorkModel> getWorkById(int id) async {
    final data = await _api.get(ApiConstants.workById(id));
    return WorkModel.fromJson(data);
  }

  Future<AssignedWorkerModel> getWorkWorker(int id) async {
    final data = await _api.get(ApiConstants.workWorker(id));
    return AssignedWorkerModel.fromJson(data);
  }
}
