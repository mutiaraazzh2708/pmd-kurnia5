import '../utils/parse.dart';

class Product {
  final int id;
  final String nama;
  final int stok;
  final int hargaEceran;
  final int hargaGrosir;

  Product({
    required this.id,
    required this.nama,
    required this.stok,
    required this.hargaEceran,
    required this.hargaGrosir,
  });

  // Harga menyesuaikan tipe pembeli
  int hargaUntuk(String tipe) =>
      tipe.toLowerCase() == 'grosir' ? hargaGrosir : hargaEceran;

  factory Product.fromJson(Map<String, dynamic> j) {
    final jual = toInt(j['harga_jual'] ?? j['harga_eceran'] ?? j['harga']);
    // harga_grosir dari API, fallback ke 90% harga_jual jika tidak ada
    final grosir = j['harga_grosir'] != null
        ? toInt(j['harga_grosir'])
        : (jual * 0.9).round();
    return Product(
      id: toInt(j['id']),
      nama: j['nama']?.toString() ?? '',
      stok: toInt(j['stok']),
      hargaEceran: jual,
      hargaGrosir: grosir,
    );
  }
}
