import '../models/product.dart';
import '../models/transaksi.dart';
import 'api_client.dart';

class KasirService {
  // ─── Produk ──────────────────────────────────────────────────────────────

  /// #47 Autocomplete produk dari API /produk/autocomplete?q=...
  static Future<List<Product>> cariProduk(String kata) async {
    final q = kata.trim();
    if (q.length >= 2) {
      try {
        final res = await ApiClient.get(
            '/produk/autocomplete?q=${Uri.encodeQueryComponent(q)}');
        final list = (res is Map ? res['data'] : res) as List;
        return list.map((e) => Product.fromJson(e)).toList();
      } catch (_) {
        // Jika endpoint bermasalah, fallback ke /produk
      }
    }

    final res = await ApiClient.get('/produk');
    final list = (res is Map ? res['data'] : res) as List;
    final semua = list.map((e) => Product.fromJson(e)).toList();
    if (q.isEmpty) return semua;
    final qLower = q.toLowerCase();
    return semua.where((p) => p.nama.toLowerCase().contains(qLower)).toList();
  }

  // ─── Transaksi ───────────────────────────────────────────────────────────

  /// #43 Simpan transaksi baru ke API.
  /// [items] berisi map: {'produk_id': id, 'jumlah': qty}
  static Future<Transaksi> simpanTransaksi({
    required List<Map<String, dynamic>> items,
    required String tipe,
    required String metode,
    int? bayar,
  }) async {
    final res = await ApiClient.post('/transaksi', {
      'tipe_pembeli': tipe == 'grosir' ? 'reseller' : 'umum',
      'metode_bayar': metode,
      'items': items,
      'bayar': bayar,
    });
    Map<String, dynamic> data;
    if (res is Map && res['transaksi'] is Map) {
      data = Map<String, dynamic>.from(res['transaksi'] as Map);
      if (res['detail'] is List) {
        final listDetail = (res['detail'] as List).map((d) {
          final mapD = Map<String, dynamic>.from(d as Map);
          if (mapD['nama'] == null) {
            // Cari nama produk dari daftar items yang dikirim
            final idx = items.indexWhere(
              (it) => it['produk_id'] == mapD['produk_id'],
            );
            if (idx >= 0 && items[idx]['nama'] != null) {
              mapD['nama'] = items[idx]['nama'];
            }
          }
          return mapD;
        }).toList();
        data['items'] = listDetail;
      }
      if (bayar != null) data['bayar'] = bayar;
    } else if (res is Map && res['data'] != null) {
      data = Map<String, dynamic>.from(res['data'] as Map);
    } else if (res is Map<String, dynamic>) {
      data = res;
    } else {
      data = {};
    }
    return Transaksi.fromJson(data);
  }

  // ─── Riwayat (US-09) ─────────────────────────────────────────────────────

  /// Mengambil daftar transaksi sesuai periode.
  /// Periode yang didukung: 'hari_ini', 'minggu_ini', 'semua'.
  static Future<List<Transaksi>> riwayat(String periode) async {
    // Semua transaksi — filter periode dilakukan di sisi klien
    final res = await ApiClient.get('/transaksi');
    final list = (res is Map ? res['data'] : res) as List;
    final semua = list.map((e) => Transaksi.fromJson(e)).toList();

    final now = DateTime.now();
    switch (periode) {
      case 'hari_ini':
        return semua.where((t) {
          final d = t.tanggal;
          return d.year == now.year && d.month == now.month && d.day == now.day;
        }).toList();
      case 'minggu_ini':
        final monday = now.subtract(Duration(days: now.weekday - 1));
        final senin = DateTime(monday.year, monday.month, monday.day);
        return semua.where((t) => t.tanggal.isAfter(senin) || t.tanggal == senin).toList();
      case 'semua':
      default:
        return semua;
    }
  }

  /// Mengambil detail satu transaksi beserta daftar item-nya.
  static Future<Transaksi> detail(int id) async {
    final res = await ApiClient.get('/transaksi/$id');
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
    await ApiClient.post('/retur', {
      'transaksi_id': transaksiId,
      'produk_id': productId,
      'jumlah': qty,
      'alasan': alasan,
    });
  }
}
