import '../models/product.dart';
import '../models/transaksi.dart';
import 'api_client.dart';

class KasirService {
  // ─── Produk ──────────────────────────────────────────────────────────────

  /// #47 Cari produk – filter lokal karena API hanya menyediakan GET /produk.
  static Future<List<Product>> cariProduk(String kata) async {
    final res = await ApiClient.get('/produk');
    final list = (res is Map ? res['data'] : res) as List;
    final semua = list.map((e) => Product.fromJson(e)).toList();
    final q = kata.trim().toLowerCase();
    if (q.isEmpty) return semua;
    return semua.where((p) => p.nama.toLowerCase().contains(q)).toList();
  }

  // ─── Transaksi ───────────────────────────────────────────────────────────

  /// #43 Simpan transaksi baru ke API.
  /// [items] berisi map: {'produk_id': id, 'jumlah': qty}
  static Future<Transaksi> simpanTransaksi({
    required List<Map<String, dynamic>> items,
    required String tipe,
    required String metode,
    required int bayar,
  }) async {
    final res = await ApiClient.post('/transaksi', {
      'tipe_pembeli': tipe == 'grosir' ? 'reseller' : 'umum',
      'metode_bayar': metode,
      'items': items,
      'bayar': bayar,
    });
    final data = (res is Map && res['data'] != null) ? res['data'] : res;
    return Transaksi.fromJson(data);
  }

  // ─── Riwayat (US-09) ─────────────────────────────────────────────────────

  /// Mengambil daftar transaksi sesuai periode.
  /// Periode yang didukung: 'hari_ini', 'minggu_ini', 'semua'.
  static Future<List<Transaksi>> riwayat(String periode) async {
    final res = await ApiClient.get('/transactions?periode=$periode');
    final list = (res is Map ? res['data'] : res) as List;
    return list.map((e) => Transaksi.fromJson(e)).toList();
  }

  /// Mengambil detail satu transaksi beserta daftar item-nya.
  static Future<Transaksi> detail(int id) async {
    final res = await ApiClient.get('/transactions/$id');
    final data = (res is Map && res['data'] != null) ? res['data'] : res;
    return Transaksi.fromJson(data);
  }

  // ─── Retur (US-10) ───────────────────────────────────────────────────────

  /// Mengirim permintaan retur ke API.
  /// Body: { transaction_id, product_id, qty, alasan }
  static Future<void> simpanRetur({
    required int transaksiId,
    required int productId,
    required int qty,
    required String alasan,
  }) async {
    await ApiClient.post('/returns', {
      'transaction_id': transaksiId,
      'product_id': productId,
      'qty': qty,
      'alasan': alasan,
    });
  }
}