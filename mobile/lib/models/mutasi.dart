class Mutasi {
  final int? id;
  final int produkId;
  final String produkNama;
  final int jumlah;
  final String asal;
  final String tujuan;
  final String tanggal;
  final String keterangan;

  Mutasi({
    this.id,
    required this.produkId,
    this.produkNama = '',
    required this.jumlah,
    required this.asal,
    required this.tujuan,
    required this.tanggal,
    this.keterangan = '',
  });

  static int _toInt(dynamic v) =>
      v is int ? v : (v is num ? v.toInt() : int.tryParse('$v') ?? 0);

  // TODO-SESUAIKAN: key JSON dengan response backend
  factory Mutasi.fromJson(Map<String, dynamic> json) {
    final produk = json['produk'];
    return Mutasi(
      id: json['id'] == null ? null : _toInt(json['id']),
      produkId: _toInt(json['produk_id']),
      produkNama: produk is Map
          ? (produk['nama']?.toString() ?? '')
          : (json['produk_nama']?.toString() ?? ''),
      jumlah: _toInt(json['jumlah']),
      asal: json['asal']?.toString() ?? '',
      tujuan: json['tujuan']?.toString() ?? '',
      tanggal: json['tanggal']?.toString() ?? '',
      keterangan: json['keterangan']?.toString() ?? '',
    );
  }
}