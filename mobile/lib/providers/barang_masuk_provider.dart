import 'package:flutter/material.dart';
import '../models/barang_masuk.dart';
import '../services/api_service.dart';
import '../services/barang_masuk_service.dart';

class BarangMasukProvider extends ChangeNotifier {
  List<BarangMasuk> _items = [];
  bool _loading = false;
  String? _error;

  List<BarangMasuk> get items => _items;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetch() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final list = await BarangMasukService.getBarangMasuk();
      _items = list
          .map((e) => BarangMasuk.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> tambah({
    required int supplierId,
    required int produkId,
    required int jumlah,
    required double hargaBeli,
    required String tanggal,
    required String keterangan,
  }) async {
    final result = await BarangMasukService.tambahBarangMasuk(
      supplierId: supplierId,
      produkId: produkId,
      jumlah: jumlah,
      hargaBeli: hargaBeli,
      tanggal: tanggal,
      keterangan: keterangan,
    );
    if (result['success'] != true) {
      throw ApiException(result['message'] ?? 'Gagal menyimpan barang masuk.');
    }
    await fetch();
  }
}