import '../models/product.dart';
import '../models/transaksi.dart';
import 'api_client.dart';

class KasirService {
  // #47 pencarian produk
  static Future<List<Product>> cariProduk(String kata) async {
    final res =
    await ApiClient.get('/products?search=${Uri.encodeQueryComponent(kata)}');
    final list = (res is Map ? res['data'] : res) as List;
    return list.map((e) => Product.fromJson(e)).toList();
  }

  // #43 simpan transaksi
  // items berisi map: {'product_id': 1, 'qty': 2}
  static Future<Transaksi> simpanTransaksi({
    required List<Map<String, dynamic>> items,
    required String tipe,
    required String metode,
  }) async {
    final res = await ApiClient.post('/transactions', {
      'tipe_pembeli': tipe,
      'metode_bayar': metode,
      'items': items,
    });
    final data = (res is Map && res['data'] != null) ? res['data'] : res;
    return Transaksi.fromJson(data);
  }

  // #48 riwayat
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

  // #44 retur
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