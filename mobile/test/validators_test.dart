import 'package:flutter_test/flutter_test.dart';
// Ganti pmd_kurnia5 dengan nilai "name:" di pubspec.yaml
import 'package:pmd_kurnia5/utils/validators.dart';

void main() {
  group('Validators.jumlah', () {
    test('kosong ditolak', () {
      expect(Validators.jumlah(''), 'Jumlah wajib diisi');
      expect(Validators.jumlah(null), 'Jumlah wajib diisi');
    });
    test('huruf dan desimal ditolak', () {
      expect(Validators.jumlah('abc'), 'Jumlah harus berupa angka bulat');
      expect(Validators.jumlah('2.5'), 'Jumlah harus berupa angka bulat');
    });
    test('0 dan negatif ditolak', () {
      expect(Validators.jumlah('0'), 'Jumlah harus lebih dari 0');
      expect(Validators.jumlah('-3'), 'Jumlah harus lebih dari 0');
    });
    test('melebihi stok ditolak', () {
      expect(Validators.jumlah('11', maxStok: 10),
          'Jumlah melebihi stok gudang (tersedia: 10)');
    });
    test('valid diterima', () {
      expect(Validators.jumlah('5', maxStok: 10), isNull);
      expect(Validators.jumlah('10', maxStok: 10), isNull);
    });
  });

  group('Validators lain', () {
    test('produk wajib', () {
      expect(Validators.produk(null), 'Pilih produk terlebih dahulu');
      expect(Validators.produk(1), isNull);
    });
    test('harga beli', () {
      expect(Validators.hargaBeli(''), 'Harga beli wajib diisi');
      expect(Validators.hargaBeli('-1'), 'Harga beli tidak boleh negatif');
      expect(Validators.hargaBeli('5000'), isNull);
    });
    test('tanggal', () {
      expect(Validators.tanggal(null), 'Tanggal wajib diisi');
      expect(Validators.tanggal(DateTime.now().add(const Duration(days: 2))),
          'Tanggal tidak boleh di masa depan');
      expect(Validators.tanggal(DateTime.now()), isNull);
    });
    test('tujuan harus beda dari asal', () {
      expect(Validators.tujuan('Toko', 'Toko'),
          'Tujuan harus berbeda dari asal');
      expect(Validators.tujuan('Toko', 'Gudang'), isNull);
    });
  });

  group('StokUtil', () {
    test('membaca stok gudang dan toko', () {
      final p = {'stok_gudang': 20, 'stok_toko': '7'};
      expect(StokUtil.gudang(p), 20);
      expect(StokUtil.toko(p), 7);
    });
    test('field tidak ada → null', () {
      expect(StokUtil.toko({'stok': 5}), isNull);
      expect(StokUtil.gudang({'stok': 5}), 5);
    });
  });
}