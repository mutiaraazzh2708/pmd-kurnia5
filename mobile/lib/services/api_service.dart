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
  // Emulator Android: 10.0.2.2. Untuk HP fisik gunakan IP WiFi laptop
  static const String baseUrl = 'http://192.168.1.17:8000/api';

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  static const _headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  // ==================== AUTH ====================

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
    required String role,
  }) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http
          .post(
            url,
            headers: _headers,
            body: jsonEncode({
              'username': username,
              'password': password,
              'role': role,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['token'] as String;
        await _storage.write(key: _tokenKey, value: token);
        if (data['user'] != null) {
          await _storage.write(
              key: 'user_name', value: data['user']['name']?.toString() ?? '');
          await _storage.write(
              key: 'user_role', value: data['user']['role']?.toString() ?? '');
        }
        ApiClient.token = token; // dipakai KasirService
        return {
          'success': true,
          'token': token,
          'user': data['user'],
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login gagal, periksa kredensial Anda.',
        };
      }
    } on SocketException {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    } on TimeoutException {
      return {'success': false, 'message': 'Koneksi timeout, coba lagi'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server ($e)'};
    }
  }

  static Future<String?> getToken() async {
    final token = await _storage.read(key: _tokenKey);
    if (token != null && ApiClient.token == null) {
      ApiClient.token = token;
    }
    return token;
  }

  static Future<String?> getUserName() async {
    return await _storage.read(key: 'user_name');
  }

  static Future<String?> getUserRole() async {
    return await _storage.read(key: 'user_role');
  }

  static Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 5));
      } catch (_) {}
    }
    ApiClient.token = null;
    await _storage.deleteAll();
  }

  static Future<void> clearToken() => logout();

  // ==================== DASHBOARD (US-06) ====================

  static Future<Map<String, dynamic>> getDashboard() async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/dashboard');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': 'Gagal mengambil data dashboard'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi error ($e)'};
    }
  }

  // ==================== PRODUK (US-02) ====================

  static Future<List<dynamic>> getProduk() async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/produk');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) return decoded;
        if (decoded is Map && decoded['data'] is List) return decoded['data'];
      }
    } catch (_) {}
    return [];
  }

  static Future<Map<String, dynamic>> tambahProduk({
    required String nama,
    required String satuanDasar,
    required double hargaBeli,
    required double hargaJual,
    required int stokAwal,
  }) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/produk');

    try {
      final response = await http
          .post(
            url,
            headers: {
              ..._headers,
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'nama': nama,
              'satuan_dasar': satuanDasar,
              'harga_beli': hargaBeli,
              'harga_jual': hargaJual,
              'stok_awal': stokAwal,
              'stok': stokAwal,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal menambahkan produk.',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi error ($e)'};
    }
  }

  static Future<Map<String, dynamic>> updateProduk({
    required int id,
    required String nama,
    required String satuanDasar,
    required double hargaBeli,
    required double hargaJual,
    required int stok,
  }) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/produk/$id');

    try {
      final response = await http
          .put(
            url,
            headers: {
              ..._headers,
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'nama': nama,
              'satuan_dasar': satuanDasar,
              'harga_beli': hargaBeli,
              'harga_jual': hargaJual,
              'stok': stok,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal memperbarui produk.',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi error ($e)'};
    }
  }

  static Future<bool> deleteProduk(int id) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/produk/$id');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
