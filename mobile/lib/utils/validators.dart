class Validators {
  // ===== Validator lama (dipakai form tambah produk) =====
  static String? wajibDiisi(String? v, String namaField) {
    if (v == null || v.trim().isEmpty) return '$namaField wajib diisi';
    return null;
  }

  static String? angkaTidakNegatif(String? v, String namaField) {
    if (v == null || v.trim().isEmpty) return '$namaField wajib diisi';
    final n = num.tryParse(v.trim());
    if (n == null) return '$namaField harus berupa angka';
    if (n < 0) return '$namaField tidak boleh negatif';
    return null;
  }

  static String? bilanganBulatTidakNegatif(String? v, String namaField) {
    if (v == null || v.trim().isEmpty) return '$namaField wajib diisi';
    final n = int.tryParse(v.trim());
    if (n == null) return '$namaField harus berupa bilangan bulat';
    if (n < 0) return '$namaField tidak boleh negatif';
    return null;
  }

  // ===== Tambahan Sprint 3 (#69): mutasi dan barang masuk =====
  static String? produk(Object? v) =>
      v == null ? 'Pilih produk terlebih dahulu' : null;

  /// [maxStok] diisi hanya untuk mutasi. Kalau null, batas stok tidak dicek.
  static String? jumlah(String? v, {int? maxStok, String lokasi = 'gudang'}) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Jumlah wajib diisi';
    final n = int.tryParse(t);
    if (n == null) return 'Jumlah harus berupa angka bulat';
    if (n <= 0) return 'Jumlah harus lebih dari 0';
    if (maxStok != null && n > maxStok) {
      return 'Jumlah melebihi stok $lokasi (tersedia: $maxStok)';
    }
    return null;
  }

  static String? hargaBeli(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Harga beli wajib diisi';
    final n = double.tryParse(t);
    if (n == null) return 'Harga beli harus berupa angka';
    if (n < 0) return 'Harga beli tidak boleh negatif';
    return null;
  }

  static String? tanggal(DateTime? d) {
    if (d == null) return 'Tanggal wajib diisi';
    final now = DateTime.now();
    final hariIni = DateTime(now.year, now.month, now.day);
    if (DateTime(d.year, d.month, d.day).isAfter(hariIni)) {
      return 'Tanggal tidak boleh di masa depan';
    }
    return null;
  }

  static String? tujuan(String? tujuan, String? asal) {
    if (tujuan == null) return 'Pilih lokasi tujuan';
    if (tujuan == asal) return 'Tujuan harus berbeda dari asal';
    return null;
  }
}

/// Membaca stok dari data produk API.
/// Mengembalikan null kalau field-nya tidak ada di respons API.
class StokUtil {
  static int? _int(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    return int.tryParse('$v');
  }

  /// Memakai 'stok_gudang'; kalau tidak ada, jatuh ke 'stok' (field lama).
  static int? gudang(dynamic p) => _int(p['stok_gudang'] ?? p['stok']);

  static int? toko(dynamic p) => _int(p['stok_toko']);
}