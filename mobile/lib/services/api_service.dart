import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/produk.dart';
import '../models/transaksi.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  // Emulator Android. Untuk HP fisik ganti ke http://<IP_LAPTOP>:8000/api
  static const String baseUrl = 'http://10.88.120.68:8000/api';

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
        await _storage.write(key: _tokenKey, value: data['token'] as String);
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

  static Future<void> clearToken() => _storage.delete(key: _tokenKey);

  // ---------------------------------------------------------------------------
  // Helper request ber-token
  // ---------------------------------------------------------------------------

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {..._headers, if (token != null) 'Authorization': 'Bearer $token'};
  }

  static Future<http.Response> _request(
      Future<http.Response> Function() call) async {
    try {
      final res = await call().timeout(const Duration(seconds: 15));
      if (res.statusCode == 401) {
        await clearToken();
        throw ApiException('Sesi habis, silakan login ulang');
      }
      return res;
    } on SocketException {
      throw ApiException('Tidak dapat terhubung ke server');
    } on TimeoutException {
      throw ApiException('Server tidak merespons, coba lagi');
    }
  }

  // Ambil pesan error pertama dari response Laravel (422 / 403 / dll).
  static String _pesanError(http.Response res, String fallback) {
    try {
      final d = jsonDecode(res.body);
      if (d is Map) {
        final errors = d['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          return (first is List ? first.first : first).toString();
        }
        if (d['message'] != null) return d['message'].toString();
      }
    } catch (_) {}
    return fallback;
  }

  // ---------------------------------------------------------------------------
  // Produk & Transaksi (#56)
  // ---------------------------------------------------------------------------

  static Future<List<Produk>> cariProduk(String kata) async {
    final headers = await _authHeaders();
    final res = await _request(() => http.get(
      Uri.parse('$baseUrl/produk')
          .replace(queryParameters: {if (kata.isNotEmpty) 'cari': kata}),
      headers: headers,
    ));
    if (res.statusCode != 200) {
      throw ApiException(_pesanError(res, 'Gagal memuat produk'));
    }
    return (jsonDecode(res.body) as List)
        .map((e) => Produk.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<Transaksi> buatTransaksi({
    required String tipePembeli,
    required String metodeBayar,
    required List<({int produkId, int jumlah})> items,
  }) async {
    final headers = await _authHeaders();
    final res = await _request(() => http.post(
      Uri.parse('$baseUrl/transaksi'),
      headers: headers,
      body: jsonEncode({
        'tipe_pembeli': tipePembeli,
        'metode_bayar': metodeBayar,
        'items': [
          for (final i in items)
            {'produk_id': i.produkId, 'jumlah': i.jumlah}
        ],
      }),
    ));
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw ApiException(_pesanError(res, 'Transaksi gagal disimpan'));
    }
    return Transaksi.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }
}