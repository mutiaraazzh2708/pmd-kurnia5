import 'package:flutter/material.dart';
import '../models/supplier.dart';
import '../services/api_service.dart';

class SupplierProvider extends ChangeNotifier {
  List<Supplier> _items = [];
  bool _loading = false;
  String? _error;
  String _query = '';

  bool get loading => _loading;
  String? get error => _error;

  List<Supplier> get items {
    if (_query.isEmpty) return _items;
    final q = _query.toLowerCase();
    return _items.where((s) => s.nama.toLowerCase().contains(q)).toList();
  }

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  Future<void> fetch() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final list = await ApiService.getSupplier();
      _items = list
          .map((e) => Supplier.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> save(Supplier s) async {
    final result = s.id == null
        ? await ApiService.tambahSupplier(
        nama: s.nama, alamat: s.alamat, telepon: s.telepon)
        : await ApiService.updateSupplier(
        id: s.id!, nama: s.nama, alamat: s.alamat, telepon: s.telepon);

    if (result['success'] != true) {
      throw ApiException(result['message'] ?? 'Gagal menyimpan supplier.');
    }
    await fetch();
  }

  Future<void> remove(int id) async {
    final ok = await ApiService.deleteSupplier(id);
    if (!ok) throw ApiException('Gagal menghapus supplier.');
    await fetch();
  }
}