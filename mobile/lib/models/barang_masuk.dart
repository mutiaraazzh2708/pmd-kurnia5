class BarangMasuk {
  final int? id;
  final int supplierId;
  final String supplierNama;
  final int produkId;
  final String produkNama;
  final int jumlah;
  final double hargaBeli;
  final String tanggal; // format yyyy-MM-dd
  final String keterangan;

  BarangMasuk({
    this.id,
    required this.supplierId,
    this.supplierNama = '',
    required this.produkId,
    this.produkNama = '',
    required this.jumlah,
    required this.hargaBeli,
    required this.tanggal,
    this.keterangan = '',
  });

  static int _toInt(dynamic v) =>
      v is int ? v : (v is num ? v.toInt() : int.tryParse('$v') ?? 0);

  static double _toDouble(dynamic v) =>
      v is num ? v.toDouble() : double.tryParse('$v') ?? 0;

  // TODO-SESUAIKAN: key JSON dengan response backend
  factory BarangMasuk.fromJson(Map<String, dynamic> json) {
    final supplier = json['supplier'];
    final produk = json['produk'];
    return BarangMasuk(
      id: json['id'] == null ? null : _toInt(json['id']),
      supplierId: _toInt(json['supplier_id']),
      supplierNama: supplier is Map
          ? (supplier['nama']?.toString() ?? '')
          : (json['supplier_nama']?.toString() ?? ''),
      produkId: _toInt(json['produk_id']),
      produkNama: produk is Map
          ? (produk['nama']?.toString() ?? '')
          : (json['produk_nama']?.toString() ?? ''),
      jumlah: _toInt(json['jumlah']),
      hargaBeli: _toDouble(json['harga_beli']),
      tanggal: json['tanggal']?.toString() ?? '',
      keterangan: json['keterangan']?.toString() ?? '',
    );
  }
}