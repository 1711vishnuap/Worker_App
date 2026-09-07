// lib/services/worker_service.dart
// Worker-side operations: profile, categories, location, available
// works, and the accept/verify-otp/complete actions on a work.

import '../config/api_constants.dart';
import '../models/work_model.dart';
import 'api_service.dart';

class WorkerService {
  final ApiService _api = ApiService();

  Future<void> createProfile() async {
    await _api.post(ApiConstants.workerProfile);
  }

  Future<void> setCategories(List<int> categoryIds) async {
    await _api.post(ApiConstants.workerCategories, body: {'category_ids': categoryIds});
  }

  Future<void> updateLocation(double lat, double lng) async {
    await _api.post(ApiConstants.workerLocation, body: {'lat': lat, 'lng': lng});
  }

  Future<List<WorkModel>> getAvailableWorks() async {
    final data = await _api.get(ApiConstants.availableWorks);
    return (data as List).map((e) => WorkModel.fromJson(e)).toList();
  }

  Future<WorkModel> acceptWork(int workId) async {
    final data = await _api.post(ApiConstants.acceptWork(workId));
    return WorkModel.fromJson(data);
  }

  Future<WorkModel> verifyOtp(int workId, String otp) async {
    final data = await _api.post(ApiConstants.verifyWorkOtp(workId), body: {'otp': otp});
    return WorkModel.fromJson(data);
  }

  Future<WorkModel> completeWork(int workId) async {
    final data = await _api.post(ApiConstants.completeWork(workId));
    return WorkModel.fromJson(data);
  }

  Future<WorkModel> getWorkById(int id) async {
    final data = await _api.get(ApiConstants.workById(id));
    return WorkModel.fromJson(data);
  }

  Future<List<WorkModel>> getWorkHistory() async {
    final data = await _api.get(ApiConstants.workerHistory);
    return (data as List).map((e) => WorkModel.fromJson(e)).toList();
  }
}
