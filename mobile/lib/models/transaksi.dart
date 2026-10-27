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

  factory TransaksiItem.fromJson(Map<String, dynamic> j) => TransaksiItem(
    productId: j['product_id'] ?? 0,
    nama: j['nama'] ?? j['product']?['nama'] ?? '',
    qty: j['qty'] ?? 0,
    harga: j['harga'] ?? 0,
  );
}

class Transaksi {
  final int id;
  final String nomor;
  final DateTime tanggal;
  final int total;
  final String metodeBayar;
  final String tipePembeli;
  final List<TransaksiItem> items;

  Transaksi({
    required this.id,
    required this.nomor,
    required this.tanggal,
    required this.total,
    required this.metodeBayar,
    required this.tipePembeli,
    required this.items,
  });

  factory Transaksi.fromJson(Map<String, dynamic> j) => Transaksi(
    id: j['id'],
    nomor: j['nomor']?.toString() ?? 'TRX-${j['id']}',
    tanggal: DateTime.tryParse(j['created_at'] ?? '') ?? DateTime.now(),
    total: j['total'] ?? 0,
    metodeBayar: j['metode_bayar'] ?? '-',
    tipePembeli: j['tipe_pembeli'] ?? '-',
    items: ((j['items'] ?? []) as List)
        .map((e) => TransaksiItem.fromJson(e))
        .toList(),
  );
}