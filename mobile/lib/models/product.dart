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
    // Kontrak hanya punya harga_jual, jadi grosir sementara sama dengan eceran.
    final jual = toInt(j['harga_jual'] ?? j['harga_eceran'] ?? j['harga']);
    return Product(
      id: toInt(j['id']),
      nama: j['nama']?.toString() ?? '',
      stok: toInt(j['stok']),
      hargaEceran: jual,
      hargaGrosir: j['harga_grosir'] != null ? toInt(j['harga_grosir']) : jual,
    );
  }
}