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

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      print('API Error: ${response.statusCode} - ${response.body}');

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
        throw ApiException(
          message: 'Request failed with status code ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    }
  }
}
