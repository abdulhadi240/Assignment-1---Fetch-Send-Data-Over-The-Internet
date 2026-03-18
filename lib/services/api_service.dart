// =============================================================================
// Flutter Assignment #1 — Todo List App
// Author : Abdul Hadi
// =============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/todo.dart';

/// Custom exception to carry a human-readable message to the UI.
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

/// All network calls go through this service.
/// Only the [http] package is used — no additional plugins.
class ApiService {
  static const String _baseUrl = 'https://apimocker.com/todos';
  static const int _timeoutSeconds = 15;

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ---------------------------------------------------------------------------
  // GET — Fetch paginated todos
  // ---------------------------------------------------------------------------
  /// Fetches up to [limit] todos for the given [page] (1-based).
  /// Most recent items are requested first (sorted descending by id/createdAt).
  Future<PaginatedTodos> fetchTodos({int page = 1, int limit = 10}) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      '_page': page.toString(),
      '_limit': limit.toString(),
      '_sort': 'id',
      '_order': 'desc',
    });

    try {
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: _timeoutSeconds));

      _assertSuccess(response);

      final dynamic body = json.decode(response.body);

      // Detect response shape and parse accordingly
      if (body is List) {
        // Some mock servers return a plain array
        final todos = body.map((e) => Todo.fromJson(e as Map<String, dynamic>)).toList();
        // Try to read X-Total-Count header
        final totalStr = response.headers['x-total-count'] ?? '0';
        final total = int.tryParse(totalStr) ?? todos.length;
        return PaginatedTodos(
          todos: todos,
          total: total > 0 ? total : (todos.length < limit ? (page - 1) * limit + todos.length : page * limit + 1),
          page: page,
          limit: limit,
        );
      } else if (body is Map<String, dynamic>) {
        if (body.containsKey('data')) {
          return PaginatedTodos.fromJson(body, page, limit);
        }
        // Single-object response wrapped in map without 'data' key
        return PaginatedTodos(
          todos: [Todo.fromJson(body)],
          total: 1,
          page: page,
          limit: limit,
        );
      }

      throw const ApiException('Unexpected response format from server.');
    } on ApiException {
      rethrow;
    } on SocketException {
      throw const ApiException('No internet connection. Please check your network.');
    } on TimeoutException {
      throw const ApiException('Request timed out. Please try again.');
    } on FormatException {
      throw const ApiException('Received invalid data from server.');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // POST — Create a new todo
  // ---------------------------------------------------------------------------
  Future<Todo> createTodo({
    required String title,
    required String description,
  }) async {
    final body = json.encode({
      'title': title.trim(),
      'description': description.trim(),
      'done': false,
    });

    try {
      final response = await http
          .post(Uri.parse(_baseUrl), headers: _headers, body: body)
          .timeout(const Duration(seconds: _timeoutSeconds));

      _assertSuccess(response, expectedCodes: [200, 201]);

      final dynamic data = json.decode(response.body);

      if (data is Map<String, dynamic>) {
        // If the response has a 'data' key, unwrap it
        final map = data.containsKey('data') ? data['data'] as Map<String, dynamic> : data;
        return Todo.fromJson(map);
      }

      throw const ApiException('Unexpected response after creating todo.');
    } on ApiException {
      rethrow;
    } on SocketException {
      throw const ApiException('No internet connection. Please check your network.');
    } on TimeoutException {
      throw const ApiException('Request timed out. Please try again.');
    } on FormatException {
      throw const ApiException('Received invalid data from server.');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // PATCH — Toggle done status
  // ---------------------------------------------------------------------------
  Future<Todo> updateTodo(String id, {required bool done}) async {
    final uri = Uri.parse('$_baseUrl/$id');
    final body = json.encode({'done': done});

    try {
      // Try PATCH first (standard REST), fall back to PUT if needed
      http.Response response = await http
          .patch(uri, headers: _headers, body: body)
          .timeout(const Duration(seconds: _timeoutSeconds));

      // Some mock servers don't support PATCH — retry with PUT
      if (response.statusCode == 405 || response.statusCode == 404) {
        response = await http
            .put(uri, headers: _headers, body: body)
            .timeout(const Duration(seconds: _timeoutSeconds));
      }

      _assertSuccess(response);

      final dynamic data = json.decode(response.body);
      if (data is Map<String, dynamic>) {
        final map = data.containsKey('data') ? data['data'] as Map<String, dynamic> : data;
        return Todo.fromJson(map);
      }

      throw const ApiException('Unexpected response after updating todo.');
    } on ApiException {
      rethrow;
    } on SocketException {
      throw const ApiException('No internet connection. Please check your network.');
    } on TimeoutException {
      throw const ApiException('Request timed out. Please try again.');
    } on FormatException {
      throw const ApiException('Received invalid data from server.');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Helper — assert HTTP success
  // ---------------------------------------------------------------------------
  void _assertSuccess(http.Response response, {List<int> expectedCodes = const [200]}) {
    if (!expectedCodes.contains(response.statusCode) &&
        response.statusCode >= 400) {
      String serverMessage = '';
      try {
        final decoded = json.decode(response.body);
        serverMessage = decoded['message']?.toString() ??
            decoded['error']?.toString() ??
            '';
      } catch (_) {}

      final suffix = serverMessage.isNotEmpty ? ': $serverMessage' : '';

      switch (response.statusCode) {
        case 400:
          throw ApiException('Bad request$suffix');
        case 401:
          throw const ApiException('Unauthorized. Please check your credentials.');
        case 403:
          throw const ApiException('Access forbidden.');
        case 404:
          throw const ApiException('Resource not found.');
        case 429:
          throw const ApiException('Too many requests. Please slow down.');
        case 500:
        case 502:
        case 503:
          throw ApiException('Server error (${response.statusCode})$suffix');
        default:
          throw ApiException('Request failed with status ${response.statusCode}$suffix');
      }
    }
  }
}
