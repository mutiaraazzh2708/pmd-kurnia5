class Validators {
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
}