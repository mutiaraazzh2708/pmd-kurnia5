class Supplier {
  final int? id;
  final String nama;
  final String alamat;
  final String telepon;

  Supplier({
    this.id,
    required this.nama,
    this.alamat = '',
    this.telepon = '',
  });

  // TODO-SESUAIKAN: key JSON dengan response backend
  factory Supplier.fromJson(Map<String, dynamic> json) => Supplier(
    id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
    nama: json['nama']?.toString() ?? '',
    alamat: json['alamat']?.toString() ?? '',
    telepon: json['telepon']?.toString() ?? '',
  );
}