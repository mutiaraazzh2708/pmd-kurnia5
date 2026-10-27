import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  String tipePembeli = 'Eceran';
  String metodeBayar = 'Tunai';

  List<CartItem> get items => List.unmodifiable(_items);
  int get jumlahItem => _items.fold(0, (s, e) => s + e.qty);
  int get total => _items.fold(0, (s, e) => s + e.subtotal(tipePembeli));

  // return pesan error (null = sukses)
  String? tambah(Product p) {
    final idx = _items.indexWhere((e) => e.product.id == p.id);
    if (idx >= 0) {
      if (_items[idx].qty + 1 > p.stok) return 'Stok ${p.nama} hanya ${p.stok}';
      _items[idx].qty++;
    } else {
      if (p.stok < 1) return 'Stok ${p.nama} habis';
      _items.add(CartItem(product: p));
    }
    notifyListeners();
    return null;
  }

  String? ubahQty(CartItem item, int qtyBaru) {
    if (qtyBaru < 1) return 'Jumlah minimal 1';
    if (qtyBaru > item.product.stok) {
      return 'Stok ${item.product.nama} hanya ${item.product.stok}';
    }
    item.qty = qtyBaru;
    notifyListeners();
    return null;
  }

  void hapus(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void setTipe(String v) {
    tipePembeli = v;
    notifyListeners();
  }

  void setMetode(String v) {
    metodeBayar = v;
    notifyListeners();
  }

  void kosongkan() {
    _items.clear();
    tipePembeli = 'Eceran';
    metodeBayar = 'Tunai';
    notifyListeners();
  }

  // #55 validasi transaksi (layar 04)
  String? validasi() {
    if (_items.isEmpty) return 'Keranjang masih kosong';
    for (final e in _items) {
      if (e.qty < 1) return 'Jumlah ${e.product.nama} minimal 1';
      if (e.qty > e.product.stok) {
        return 'Stok ${e.product.nama} tidak cukup (sisa ${e.product.stok})';
      }
    }
    return null;
  }
}