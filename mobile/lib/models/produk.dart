int _toInt(dynamic v) =>
    v == null ? 0 : (num.tryParse(v.toString()) ?? 0).round();

class Produk {
  final int id;
  final String nama;
  final int hargaUmum;
  final int hargaGrosir;
  final int stok;
  final String satuan;

  Produk({
    required this.id,
    required this.nama,
    required this.hargaUmum,
    required this.hargaGrosir,
    required this.stok,
    required this.satuan,
  });

  factory Produk.fromJson(Map<String, dynamic> j) {
    final umum = _toInt(j['harga_jual']);
    return Produk(
      id: j['id'] as int,
      nama: j['nama'].toString(),
      hargaUmum: umum,
      // API belum punya harga grosir, sementara sama dengan harga umum.
      hargaGrosir: j['harga_grosir'] != null ? _toInt(j['harga_grosir']) : umum,
      stok: _toInt(j['stok']),
      satuan: (j['satuan'] is Map) ? j['satuan']['nama'].toString() : '',
    );
  }
}