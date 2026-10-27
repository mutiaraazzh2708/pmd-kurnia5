import '../utils/parse.dart';

class TransaksiItem {
  final int productId;
  final String nama;
  final int qty;
  final int harga;

  TransaksiItem({
    required this.productId,
    required this.nama,
    required this.qty,
    required this.harga,
  });

  // Mendukung nama field kontrak (produk_id, jumlah) dan nama lama.
  factory TransaksiItem.fromJson(Map<String, dynamic> j) => TransaksiItem(
    productId: toInt(j['produk_id'] ?? j['product_id']),
    nama: j['nama']?.toString() ??
        j['produk']?['nama']?.toString() ??
        j['product']?['nama']?.toString() ??
        '',
    qty: toInt(j['jumlah'] ?? j['qty']),
    harga: toInt(j['harga']),
  );
}

class Transaksi {
  final int id;
  final String nomor;
  final DateTime tanggal;
  final int total;
  final int bayar;
  final int kembalian;
  final String metodeBayar;
  final String tipePembeli;
  final List<TransaksiItem> items;

  Transaksi({
    required this.id,
    required this.nomor,
    required this.tanggal,
    required this.total,
    this.bayar = 0,
    this.kembalian = 0,
    required this.metodeBayar,
    required this.tipePembeli,
    required this.items,
  });

  factory Transaksi.fromJson(Map<String, dynamic> j) => Transaksi(
    id: toInt(j['id']),
    nomor: j['nomor']?.toString() ?? 'TRX-${j['id']}',
    tanggal: DateTime.tryParse(j['created_at']?.toString() ?? '') ??
        DateTime.now(),
    total: toInt(j['total']),
    bayar: toInt(j['bayar']),
    kembalian: toInt(j['kembalian']),
    metodeBayar: j['metode_bayar']?.toString() ?? '-',
    tipePembeli: j['tipe_pembeli']?.toString() ?? '-',
    items: ((j['items'] ?? []) as List)
        .map((e) => TransaksiItem.fromJson(e))
        .toList(),
  );
}