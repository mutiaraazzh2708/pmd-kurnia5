import 'package:flutter/foundation.dart';

import '../models/produk.dart';
import '../models/transaksi.dart';
import '../services/api_service.dart';

class ItemKeranjang {
  final Produk produk;
  int jumlah;
  ItemKeranjang(this.produk, {this.jumlah = 1});
}

class KeranjangProvider extends ChangeNotifier {
  final List<ItemKeranjang> _items = [];
  String _tipePembeli = 'umum';
  String _metodeBayar = 'tunai';
  bool _loading = false;
  String? _error;

  List<ItemKeranjang> get items => List.unmodifiable(_items);
  String get tipePembeli => _tipePembeli;
  String get metodeBayar => _metodeBayar;
  bool get loading => _loading;
  String? get error => _error;
  int get jumlahItem => _items.fold(0, (s, i) => s + i.jumlah);

  int harga(ItemKeranjang i) =>
      _tipePembeli == 'umum' ? i.produk.hargaUmum : i.produk.hargaGrosir;

  int get total => _items.fold(0, (s, i) => s + harga(i) * i.jumlah);

  set tipePembeli(String v) {
    _tipePembeli = v;
    notifyListeners();
  }

  set metodeBayar(String v) {
    _metodeBayar = v;
    notifyListeners();
  }

  /// Mengembalikan pesan error bila gagal, null bila berhasil.
  String? tambah(Produk p) {
    final idx = _items.indexWhere((i) => i.produk.id == p.id);
    final sudah = idx >= 0 ? _items[idx].jumlah : 0;
    if (p.stok <= 0) return '${p.nama} stoknya habis';
    if (sudah + 1 > p.stok) {
      return 'Stok ${p.nama} tidak cukup (tersisa ${p.stok})';
    }
    if (idx >= 0) {
      _items[idx].jumlah++;
    } else {
      _items.add(ItemKeranjang(p));
    }
    notifyListeners();
    return null;
  }

  String? ubahJumlah(ItemKeranjang item, int delta) {
    final baru = item.jumlah + delta;
    if (baru > item.produk.stok) {
      return 'Stok ${item.produk.nama} tidak cukup (tersisa ${item.produk.stok})';
    }
    if (baru <= 0) {
      _items.remove(item);
    } else {
      item.jumlah = baru;
    }
    notifyListeners();
    return null;
  }

  void hapus(ItemKeranjang item) {
    _items.remove(item);
    notifyListeners();
  }

  void kosongkan() {
    _items.clear();
    _error = null;
    notifyListeners();
  }

  /// Validasi sebelum konfirmasi bayar.
  String? validasi() {
    if (_items.isEmpty) return 'Keranjang masih kosong';
    for (final i in _items) {
      if (i.jumlah < 1) return 'Jumlah ${i.produk.nama} tidak valid';
      if (i.jumlah > i.produk.stok) {
        return 'Stok ${i.produk.nama} tidak cukup (tersisa ${i.produk.stok})';
      }
    }
    return null;
  }

  /// POST transaksi. Mengembalikan Transaksi bila sukses, null bila gagal
  /// (pesan ada di [error]).
  Future<Transaksi?> bayar() async {
    final v = validasi();
    if (v != null) {
      _error = v;
      notifyListeners();
      return null;
    }
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final trx = await ApiService.buatTransaksi(
        tipePembeli: _tipePembeli,
        metodeBayar: _metodeBayar,
        items: [for (final i in _items) (produkId: i.produk.id, jumlah: i.jumlah)],
      );
      _items.clear();
      return trx;
    } on ApiException catch (e) {
      _error = e.message;
      return null;
    } catch (_) {
      _error = 'Terjadi kesalahan, coba lagi';
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}