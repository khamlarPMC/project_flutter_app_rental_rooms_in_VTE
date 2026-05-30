import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_constants.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;

  ApiException({required this.message, required this.statusCode, this.errors});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class ApiService {
  // Base URL ดึงมาจาก AppApi.baseUrl ใน app_constants.dart
  static String get baseUrl => AppApi.baseUrl;

  // You should store and retrieve this token using a package like flutter_secure_storage
  static String? authToken;

  static Map<String, String> get headers {
    var h = {'Content-Type': 'application/json', 'Accept': 'application/json'};
    if (authToken != null) {
      h['Authorization'] = 'Bearer $authToken';
    }
    return h;
  }

  // Example generic GET request
  static Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(url, headers: headers);
    return _handleResponse(response);
  }

  // Example generic POST request
  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');
    debugPrint('API POST: $url');
    debugPrint('API HEADERS: $headers');
    debugPrint('API BODY: ${jsonEncode(data)}');
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  // Example generic PATCH request
  static Future<dynamic> patch(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.patch(
      url,
      headers: headers,
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  // Example generic PUT request
  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  // Example generic DELETE request
  static Future<dynamic> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.delete(url, headers: headers);
    return _handleResponse(response);
  }

  // Generic Multipart POST request for file uploads
  static Future<dynamic> postMultipart(
    String endpoint,
    Map<String, String> fields,
    List<http.MultipartFile> files,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');
    var request = http.MultipartRequest('POST', url);

    // Add headers
    request.headers.addAll({
      'Accept': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    });

    // Add text fields
    request.fields.addAll(fields);

    // Add files
    request.files.addAll(files);

    // Debug logging for multipart
    debugPrint('API MULTIPART POST: $url');
    debugPrint('API MULTIPART HEADERS: ${request.headers}');
    debugPrint('API MULTIPART FIELDS: ${request.fields}');
    debugPrint('API MULTIPART FILES: ${request.files.map((f) => '${f.field}:${f.filename}').toList()}');

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    debugPrint('API MULTIPART RESPONSE: ${response.statusCode} - ${response.body}');
    return _handleResponse(response);
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      debugPrint('API Error: ${response.statusCode} - ${response.body}');

      try {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final message = errorData['message'] ?? 'Request failed';
        final errors = errorData['errors'] as Map<String, dynamic>?;

        throw ApiException(
          message: message,
          statusCode: response.statusCode,
          errors: errors,
        );
      } catch (e) {
        if (e is ApiException) {
          rethrow;
        }

        final cleanBody = response.body.trim();
        final message = cleanBody.isNotEmpty
            ? 'Request failed with status code ${response.statusCode}: ${cleanBody.length > 120 ? '${cleanBody.substring(0, 120)}...' : cleanBody}'
            : 'Request failed with status code ${response.statusCode}';

        throw ApiException(
          message: message,
          statusCode: response.statusCode,
        );
      }
    }
  }
}
