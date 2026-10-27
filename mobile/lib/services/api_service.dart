import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'api_client.dart' show ApiClient;

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  // Emulator Android. Untuk HP fisik ganti ke http://<IP_LAPTOP>:8000/api
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  static const _headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  static Future<Map<String, dynamic>> login(
      String username,
      String password,
      String role,
      ) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/login'),
        headers: _headers,
        body: jsonEncode({
          'username': username,
          'password': password,
          'role': role,
        }),
      )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final token = data['token'] as String;
        await _storage.write(key: _tokenKey, value: token);
        ApiClient.token = token; // dipakai KasirService
        return data;
      }

      // 401 / 422: pesan dari backend
      throw ApiException(data['message']?.toString() ?? 'Login gagal');
    } on SocketException {
      throw ApiException('Tidak dapat terhubung ke server');
    } on TimeoutException {
      throw ApiException('Server tidak merespons, coba lagi');
    } on FormatException {
      throw ApiException('Respons server tidak valid');
    }
  }

  static Future<String?> getToken() => _storage.read(key: _tokenKey);

  static Future<void> clearToken() async {
    ApiClient.token = null;
    await _storage.delete(key: _tokenKey);
  }
}