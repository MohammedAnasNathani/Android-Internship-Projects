import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  Future<dynamic> get(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(Uri.parse('$baseUrl/$endpoint'));
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body.isNotEmpty ? json.decode(response.body) : null;
    } else if (response.statusCode == 400) {
      throw BadRequestException(response.body);
    } else if (response.statusCode == 404) {
      throw NotFoundException(response.body);
    } else {
      throw Exception('Failed to communicate with the server: ${response.statusCode}');
    }
  }
}

class BadRequestException implements Exception {
  final String message;
  BadRequestException(this.message);
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
}