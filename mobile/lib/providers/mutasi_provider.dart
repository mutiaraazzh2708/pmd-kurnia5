import 'package:flutter/material.dart';
import '../models/mutasi.dart';
import '../services/api_service.dart';
import '../services/mutasi_service.dart';

class MutasiProvider extends ChangeNotifier {
  List<Mutasi> _items = [];
  bool _loading = false;
  String? _error;

  List<Mutasi> get items => _items;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetch() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final list = await MutasiService.getMutasi();
      _items = list
          .map((e) => Mutasi.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> tambah({
    required int produkId,
    required int jumlah,
    required String asal,
    required String tujuan,
    required String tanggal,
    required String keterangan,
  }) async {
    final result = await MutasiService.tambahMutasi(
      produkId: produkId,
      jumlah: jumlah,
      asal: asal,
      tujuan: tujuan,
      tanggal: tanggal,
      keterangan: keterangan,
    );
    if (result['success'] != true) {
      throw ApiException(result['message'] ?? 'Gagal menyimpan mutasi.');
    }
    await fetch();
  }
}