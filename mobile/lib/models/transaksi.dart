int _toInt(dynamic v) =>
    v == null ? 0 : (num.tryParse(v.toString()) ?? 0).round();

class DetailTransaksi {
  final String nama;
  final int jumlah;
  final int harga;
  final int subtotal;

  DetailTransaksi({
    required this.nama,
    required this.jumlah,
    required this.harga,
    required this.subtotal,
  });

  factory DetailTransaksi.fromJson(Map<String, dynamic> j) => DetailTransaksi(
    nama: (j['produk'] is Map) ? j['produk']['nama'].toString() : '-',
    jumlah: _toInt(j['jumlah']),
    harga: _toInt(j['harga']),
    subtotal: _toInt(j['subtotal']),
  );
}

class Transaksi {
  final int id;
  final String tipePembeli;
  final String metodeBayar;
  final int total;
  final DateTime? createdAt;
  final List<DetailTransaksi> detail;

  Transaksi({
    required this.id,
    required this.tipePembeli,
    required this.metodeBayar,
    required this.total,
    required this.createdAt,
    required this.detail,
  });

  factory Transaksi.fromJson(Map<String, dynamic> j) => Transaksi(
    id: j['id'] as int,
    tipePembeli: j['tipe_pembeli'].toString(),
    metodeBayar: j['metode_bayar'].toString(),
    total: _toInt(j['total']),
    createdAt: DateTime.tryParse(j['created_at']?.toString() ?? '')?.toLocal(),
    detail: ((j['detail'] ?? []) as List)
        .map((e) => DetailTransaksi.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}