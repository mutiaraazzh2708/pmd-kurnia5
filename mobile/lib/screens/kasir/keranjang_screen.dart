import 'package:flutter/material.dart';
import '../../services/kasir_service.dart';
import '../../utils/format.dart';
import '../struk_screen.dart';

class ItemKeranjang {
  final int productId;
  final String nama;
  final int hargaEceran;
  final int hargaGrosir;
  final int stok;
  int jumlah;

  ItemKeranjang({
    required this.productId,
    required this.nama,
    required this.hargaEceran,
    required this.hargaGrosir,
    required this.stok,
    this.jumlah = 1,
  });
}

class KeranjangScreen extends StatefulWidget {
  final List<ItemKeranjang> items;
  final String tipeAwal;

  const KeranjangScreen({
    super.key,
    required this.items,
    this.tipeAwal = 'eceran',
  });

  @override
  State<KeranjangScreen> createState() => _KeranjangScreenState();
}

class _KeranjangScreenState extends State<KeranjangScreen> {
  late final List<ItemKeranjang> _items = widget.items;

  late String _tipePembeli = widget.tipeAwal; // 'eceran' atau 'grosir'
  String _metodeBayar = 'tunai'; // 'tunai', 'transfer', 'qris'

  bool _menyimpan = false;
  String? _errorValidasi;

  int _harga(ItemKeranjang i) =>
      _tipePembeli == 'eceran' ? i.hargaEceran : i.hargaGrosir;

  int get _total => _items.fold(0, (sum, i) => sum + _harga(i) * i.jumlah);

  void _snack(String pesan, {bool error = true}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  void _ubahJumlah(ItemKeranjang item, int delta) {
    if (delta > 0 && item.jumlah + delta > item.stok) {
      _snack('Stok ${item.nama} hanya tersisa ${item.stok}');
      return;
    }
    setState(() {
      item.jumlah += delta;
      if (item.jumlah <= 0) {
        _items.remove(item);
      }
      _errorValidasi = null;
    });
  }

  String? _validasi() {
    if (_items.isEmpty) return 'Keranjang masih kosong';
    for (final i in _items) {
      if (i.jumlah < 1) return 'Jumlah ${i.nama} minimal 1';
      if (i.jumlah > i.stok) {
        return 'Stok ${i.nama} tidak cukup (sisa ${i.stok})';
      }
    }
    if (_metodeBayar.isEmpty) return 'Metode bayar wajib dipilih';
    return null;
  }

  Future<void> _bayar() async {
    setState(() => _menyimpan = true);
    try {
      final trx = await KasirService.simpanTransaksi(
        items: _items
            .map((i) => {
                  'produk_id': i.productId,
                  'jumlah': i.jumlah,
                  'nama': i.nama,
                })
            .toList(),
        tipe: _tipePembeli,
        metode: _metodeBayar,
        bayar: _total,
      );

      _items.clear();
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => StrukScreen(transaksi: trx)),
      );
    } catch (e) {
      if (mounted) _snack(e.toString());
    } finally {
      if (mounted) setState(() => _menyimpan = false);
    }
  }

  void _konfirmasi() {
    final err = _validasi();
    setState(() => _errorValidasi = err);
    if (err != null) {
      _snack(err);
      return;
    }

    const kPrimary = Color(0xFF1B3252);
    final tipeLabel = _tipePembeli == 'eceran' ? 'Umum' : 'Reseller';
    final metodeLabel = _metodeBayar.toUpperCase();

    // Dialog Konfirmasi sesuai Figma 05 - KONFIRMASI SIMPAN
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Simpan transaksi?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: kPrimary,
            fontSize: 20,
          ),
        ),
        content: Text(
          'Total ${rupiah(_total)} ($tipeLabel, $metodeLabel). Stok toko akan berkurang sesuai jumlah.',
          style: TextStyle(color: Colors.grey.shade700, fontSize: 14, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kPrimary,
                    side: const BorderSide(color: kPrimary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _bayar();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const kPrimary = Color(0xFF1B3252);
    const kBg = Color(0xFFF4F6F9);

    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          // Header curved navy
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: kPrimary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KASIR',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Keranjang',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Konten Keranjang
          Expanded(
            child: _items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.remove_shopping_cart_outlined,
                            size: 56, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'Keranjang masih kosong',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Segmented Pembeli Umum / Reseller
                      Container(
                        height: 44,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5EDF6),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _tipePembeli = 'eceran'),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: _tipePembeli == 'eceran'
                                        ? kPrimary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Pembeli Umum',
                                    style: TextStyle(
                                      color: _tipePembeli == 'eceran'
                                          ? Colors.white
                                          : kPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _tipePembeli = 'grosir'),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: _tipePembeli == 'grosir'
                                        ? kPrimary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Reseller',
                                    style: TextStyle(
                                      color: _tipePembeli == 'grosir'
                                          ? Colors.white
                                          : kPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Daftar Item Keranjang
                      for (final item in _items) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: item.jumlah <= 0
                                  ? Colors.red.shade400
                                  : Colors.grey.shade200,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.nama,
                                          style: const TextStyle(
                                            color: kPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _tipePembeli == 'eceran'
                                              ? rupiah(item.hargaEceran)
                                              : 'Reseller ${rupiah(item.hargaGrosir)}',
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Stepper [-] qty [+]
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => _ubahJumlah(item, -1),
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFD8EAFD),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.remove,
                                            size: 16,
                                            color: kPrimary,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14),
                                        child: Text(
                                          '${item.jumlah}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: kPrimary,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => _ubahJumlah(item, 1),
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFD8EAFD),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            size: 16,
                                            color: kPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (item.jumlah <= 0) ...[
                                const SizedBox(height: 8),
                                const Text(
                                  'Jumlah harus lebih dari 0',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 11),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),

                      // METODE BAYAR
                      Text(
                        'METODE BAYAR',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Container(
                        height: 44,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _errorValidasi != null &&
                                    _metodeBayar.isEmpty
                                ? Colors.red
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            for (final m in ['tunai', 'transfer', 'qris'])
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _metodeBayar = m),
                                  child: AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: _metodeBayar == m
                                          ? kPrimary
                                          : Colors.transparent,
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      m == 'qris'
                                          ? 'QRIS'
                                          : m[0].toUpperCase() +
                                              m.substring(1),
                                      style: TextStyle(
                                        color: _metodeBayar == m
                                          ? Colors.white
                                          : kPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      if (_errorValidasi != null) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _errorValidasi!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12),
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Box TOTAL (Light Blue Banner Sesuai Figma)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBF3FC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFD4E6FA)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TOTAL',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              rupiah(_total),
                              style: const TextStyle(
                                color: kPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Tombol Bayar & Kembali
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: (_items.isEmpty || _menyimpan)
                              ? null
                              : _konfirmasi,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _menyimpan
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Text(
                                  'Bayar',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kPrimary,
                            side: const BorderSide(color: kPrimary, width: 1.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Kembali',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
