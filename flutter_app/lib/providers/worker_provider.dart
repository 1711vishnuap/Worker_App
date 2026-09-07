// lib/providers/worker_provider.dart
// Holds WORKER-side state: available works list, the currently
// accepted work, and selected categories.

import 'package:flutter/foundation.dart';
import '../models/work_model.dart';
import '../services/worker_service.dart';

class WorkerProvider extends ChangeNotifier {
  final WorkerService _workerService = WorkerService();

  List<WorkModel> availableWorks = [];
  WorkModel? acceptedWork;

  bool isLoading = false;
  String? errorMessage;

  Future<void> ensureProfile() async {
    try {
      await _workerService.createProfile();
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  Future<bool> setCategories(List<int> categoryIds) async {
    isLoading = true;
    notifyListeners();
    try {
      await _workerService.setCategories(categoryIds);
      errorMessage = null;
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateLocation(double lat, double lng) async {
    try {
      await _workerService.updateLocation(lat, lng);
    } catch (e) {
      // Silent — location pings shouldn't interrupt the UI with errors.
      debugPrint('Failed to update location: $e');
    }
  }

  Future<void> loadAvailableWorks() async {
    isLoading = true;
    notifyListeners();
    try {
      availableWorks = await _workerService.getAvailableWorks();
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> acceptWork(int workId) async {
    isLoading = true;
    notifyListeners();
    try {
      acceptedWork = await _workerService.acceptWork(workId);
      errorMessage = null;
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp(int workId, String otp) async {
    isLoading = true;
    notifyListeners();
    try {
      acceptedWork = await _workerService.verifyOtp(workId, otp);
      errorMessage = null;
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> completeWork(int workId) async {
    isLoading = true;
    notifyListeners();
    try {
      acceptedWork = await _workerService.completeWork(workId);
      errorMessage = null;
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<WorkModel> history = [];

  Future<void> loadHistory() async {
    isLoading = true;
    notifyListeners();
    try {
      history = await _workerService.getWorkHistory();
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadWorkById(int id) async {
    isLoading = true;
    notifyListeners();
    try {
      acceptedWork = await _workerService.getWorkById(id);
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
