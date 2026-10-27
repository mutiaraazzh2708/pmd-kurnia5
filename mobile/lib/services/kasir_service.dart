import '../models/product.dart';
import '../models/transaksi.dart';
import 'api_client.dart';

class KasirService {
  // #47 pencarian produk (kontrak hanya punya GET /produk, jadi filter di aplikasi)
  static Future<List<Product>> cariProduk(String kata) async {
    final res = await ApiClient.get('/produk');
    final list = (res is Map ? res['data'] : res) as List;
    final semua = list.map((e) => Product.fromJson(e)).toList();
    final q = kata.trim().toLowerCase();
    if (q.isEmpty) return semua;
    return semua.where((p) => p.nama.toLowerCase().contains(q)).toList();
  }

  // #43 simpan transaksi
  // items berisi map: {'produk_id': 1, 'jumlah': 2}
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

  // #48 riwayat (endpoint belum ada di kontrak)
  static Future<List<Transaksi>> riwayat(String periode) async {
    final res = await ApiClient.get('/transactions?periode=$periode');
    final list = (res is Map ? res['data'] : res) as List;
    return list.map((e) => Transaksi.fromJson(e)).toList();
  }

  static Future<Transaksi> detail(int id) async {
    final res = await ApiClient.get('/transactions/$id');
    final data = (res is Map && res['data'] != null) ? res['data'] : res;
    return Transaksi.fromJson(data);
  }

  // #44 retur (endpoint belum ada di kontrak)
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