// lib/providers/work_provider.dart
// Holds CUSTOMER-side state: category list, "my works", and whichever
// single work is currently being viewed/tracked.

import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import '../models/work_model.dart';
import '../services/work_service.dart';

class WorkProvider extends ChangeNotifier {
  final WorkService _workService = WorkService();

  List<CategoryModel> categories = [];
  List<WorkModel> myWorks = [];
  WorkModel? currentWork;
  AssignedWorkerModel? assignedWorker;

  bool isLoading = false;
  String? errorMessage;
  bool categoriesLoading = false;
  String? categoriesError;

  Future<void> loadCategories() async {
    if (categoriesLoading) return;
    categoriesLoading = true;
    categoriesError = null;
    notifyListeners();
    try {
      categories = await _workService.getCategories();
    } catch (e) {
      categoriesError = e.toString();
    } finally {
      categoriesLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createWork({
    required int categoryId,
    required String title,
    String? description,
    String? photoUrl,
    required double lat,
    required double lng,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      currentWork = await _workService.createWork(
        categoryId: categoryId,
        title: title,
        description: description,
        photoUrl: photoUrl,
        lat: lat,
        lng: lng,
      );
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

  Future<void> loadMyWorks() async {
    isLoading = true;
    notifyListeners();
    try {
      myWorks = await _workService.getMyWorks();
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
      currentWork = await _workService.getWorkById(id);
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAssignedWorker(int workId) async {
    try {
      assignedWorker = await _workService.getWorkWorker(workId);
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> updateWork(int workId,
      {required String title, String? description}) async {
    isLoading = true;
    notifyListeners();
    try {
      final updated = await _workService.updateWork(workId,
          title: title, description: description);
      currentWork = updated;
      final idx = myWorks.indexWhere((w) => w.id == workId);
      if (idx != -1) myWorks[idx] = updated;
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

  Future<bool> cancelWork(int workId) async {
    isLoading = true;
    notifyListeners();
    try {
      await _workService.cancelWork(workId);
      myWorks = myWorks.map((w) {
        if (w.id == workId) return w.copyWithStatus(WorkStatus.cancelled);
        return w;
      }).toList();
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
}
