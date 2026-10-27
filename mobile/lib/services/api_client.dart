import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiClient {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  // Isi token ini dari login Sprint 1 (ApiClient.token = hasilLogin.token)
  static String? token;

  static Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  static dynamic _handle(http.Response res) {
    final body = res.body.isEmpty ? null : jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    final msg = (body is Map && body['message'] != null)
        ? body['message'].toString()
        : 'Terjadi kesalahan (${res.statusCode})';
    throw ApiException(msg);
  }

  static Future<dynamic> get(String path) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl$path'), headers: _headers);
      return _handle(res);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Tidak dapat terhubung ke server');
    }
  }

  static Future<dynamic> post(String path, Map<String, dynamic> data) async {
    try {
      final res = await http.post(Uri.parse('$baseUrl$path'),
          headers: _headers, body: jsonEncode(data));
      return _handle(res);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Tidak dapat terhubung ke server');
    }
  }
}