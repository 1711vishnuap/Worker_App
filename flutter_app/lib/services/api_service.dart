// lib/services/api_service.dart
//
// THE ONLY PLACE IN THE APP THAT MAKES HTTP CALLS.
// Every feature service (auth_service, work_service, worker_service)
// calls through here instead of using `http` directly. This means:
//   - the base URL lives in one place (api_constants.dart)
//   - the JWT token is attached automatically on every request
//   - error handling / response parsing is consistent everywhere

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_constants.dart';
import 'api_exception.dart';
import 'storage_service.dart';

class ApiService {
  final StorageService _storage = StorageService();

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await _storage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Uri _uri(String path) => Uri.parse('${ApiConstants.baseUrl}$path');

  /// Parses the standard `{ success, message, data }` response shape
  /// used by every endpoint on the backend, and throws ApiException
  /// on failure so callers can just try/catch.
  dynamic _handleResponse(http.Response response) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('Unexpected server response', statusCode: response.statusCode);
    }

    final success = body['success'] == true;
    if (!success) {
      throw ApiException(
        body['message']?.toString() ?? 'Something went wrong',
        statusCode: response.statusCode,
      );
    }
    return body['data'];
  }

  Future<dynamic> get(String path, {bool auth = true}) async {
    try {
      final response = await http
          .get(_uri(path), headers: await _headers(auth: auth))
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Could not connect to server. Check your internet connection.');
    }
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body, bool auth = true}) async {
    try {
      final response = await http
          .post(
            _uri(path),
            headers: await _headers(auth: auth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Could not connect to server. Check your internet connection.');
    }
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body, bool auth = true}) async {
    try {
      final response = await http
          .put(
            _uri(path),
            headers: await _headers(auth: auth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Could not connect to server. Check your internet connection.');
    }
  }
}
