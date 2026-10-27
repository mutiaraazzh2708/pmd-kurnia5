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
  int hargaUntuk(String tipe) => tipe == 'Grosir' ? hargaGrosir : hargaEceran;

  factory Product.fromJson(Map<String, dynamic> j) => Product(
    id: j['id'],
    nama: j['nama'] ?? '',
    stok: j['stok'] ?? 0,
    hargaEceran: j['harga_eceran'] ?? j['harga'] ?? 0,
    hargaGrosir: j['harga_grosir'] ?? j['harga'] ?? 0,
  );
}