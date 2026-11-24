import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_service.dart';

class MutasiService {
  static Future<Map<String, String>> _headers({bool json = false}) async {
    final token = await ApiService.getToken();
    return {
      'Accept': 'application/json',
      if (json) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // TODO-SESUAIKAN: endpoint '/mutasi' dengan backend
  static Future<List<dynamic>> getMutasi() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiService.baseUrl}/mutasi'),
          headers: await _headers())
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) return decoded;
        if (decoded is Map && decoded['data'] is List) return decoded['data'];
        return [];
      }
      throw ApiException('Gagal memuat mutasi (${response.statusCode})');
    } on SocketException {
      throw ApiException('Tidak dapat terhubung ke server');
    } on TimeoutException {
      throw ApiException('Koneksi timeout, coba lagi');
    }
  }

  static Future<Map<String, dynamic>> tambahMutasi({
    required int produkId,
    required int jumlah,
    required String asal,
    required String tujuan,
    required String tanggal,
    required String keterangan,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse('${ApiService.baseUrl}/mutasi'),
        headers: await _headers(json: true),
        body: jsonEncode({
          'produk_id': produkId,
          'jumlah': jumlah,
          'asal': asal,
          'tujuan': tujuan,
          'tanggal': tanggal,
          'keterangan': keterangan,
        }),
      )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': data};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal menyimpan mutasi.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Koneksi error ($e)'};
    }
  }
}