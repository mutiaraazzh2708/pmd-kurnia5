import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/kasir_service.dart';
import '../../utils/format.dart';
import '../../widgets/kasir_bottom_nav.dart';
import 'keranjang_screen.dart';

class KasirScreen extends StatefulWidget {
  const KasirScreen({super.key});

  @override
  State<KasirScreen> createState() => _KasirScreenState();
}

class _KasirScreenState extends State<KasirScreen> {
  final _cariCtrl = TextEditingController();
  Timer? _debounce;

  final List<ItemKeranjang> _keranjang = [];
  List<Product> _hasil = [];
  bool _loading = false;
  String? _error;

  String _tipePembeli = 'umum'; // 'umum' (eceran) atau 'reseller' (grosir)

  int get _jumlahItem => _keranjang.fold(0, (s, i) => s + i.jumlah);
  int get _total => _keranjang.fold(
        0,
        (s, i) =>
            s +
            (_tipePembeli == 'umum' ? i.hargaEceran : i.hargaGrosir) * i.jumlah,
      );

  @override
  void initState() {
    super.initState();
    _cari('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _cariCtrl.dispose();
    super.dispose();
  }

  void _onChanged(String teks) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      final q = teks.trim();
      if (q.length == 1) return;
      _cari(q);
    });
  }

  Future<void> _cari(String q) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await KasirService.cariProduk(q);
      if (!mounted) return;
      setState(() => _hasil = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String pesan, {bool error = true}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(pesan),
      backgroundColor: error ? Colors.red : Colors.green,
      duration: const Duration(seconds: 1),
    ));
  }

  void _tambah(Product p) {
    final idx = _keranjang.indexWhere((e) => e.productId == p.id);
    if (idx >= 0) {
      if (_keranjang[idx].jumlah + 1 > p.stok) {
        _snack('Stok ${p.nama} hanya ${p.stok}');
        return;
      }
      setState(() => _keranjang[idx].jumlah++);
    } else {
      if (p.stok < 1) {
        _snack('Stok ${p.nama} habis');
        return;
      }
      setState(() => _keranjang.add(ItemKeranjang(
            productId: p.id,
            nama: p.nama,
            hargaEceran: p.hargaEceran,
            hargaGrosir: p.hargaGrosir,
            stok: p.stok,
          )));
    }
    _snack('${p.nama} ditambahkan ke keranjang', error: false);
  }

  Widget _kartuProduk(Product p) {
    const kPrimary = Color(0xFF1B3252);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _tambah(p),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Badge STOK kotak biru muda
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8EAFD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'STOK',
                        style: TextStyle(
                          color: kPrimary,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${p.stok}',
                        style: const TextStyle(
                          color: kPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 14),

                // Nama & Satuan
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.nama,
                        style: const TextStyle(
                          color: kPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Satuan: Eceran',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Harga: tampilkan harga aktif sesuai tipe pembeli
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (p.hargaGrosir != p.hargaEceran)
                      Text(
                        _tipePembeli == 'umum'
                            ? 'Grosir ${rupiah(p.hargaGrosir)}'
                            : 'Eceran ${rupiah(p.hargaEceran)}',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      ),
                    if (p.hargaGrosir != p.hargaEceran)
                      const SizedBox(height: 3),
                    Text(
                      rupiah(_tipePembeli == 'umum' ? p.hargaEceran : p.hargaGrosir),
                      style: const TextStyle(
                        color: kPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
                padding: const EdgeInsets.fromLTRB(24, 16, 20, 24),
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
                      'Transaksi Baru',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Segmented Tipe Pembeli (Pembeli Umum / Reseller)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
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
                      onTap: () => setState(() => _tipePembeli = 'umum'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: _tipePembeli == 'umum'
                              ? kPrimary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Pembeli Umum',
                          style: TextStyle(
                            color: _tipePembeli == 'umum'
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
                      onTap: () => setState(() => _tipePembeli = 'reseller'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: _tipePembeli == 'reseller'
                              ? kPrimary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Reseller',
                          style: TextStyle(
                            color: _tipePembeli == 'reseller'
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
          ),

          // Search Box Pill Sesuai Figma
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _cariCtrl,
                onChanged: _onChanged,
                decoration: InputDecoration(
                  prefixIcon:
                      Icon(Icons.search, color: Colors.grey.shade500, size: 22),
                  hintText: 'Cari produk...',
                  hintStyle:
                      TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // Daftar Produk
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: kPrimary))
                : _error != null
                    ? Center(
                        child: Text(_error!,
                            style: const TextStyle(color: Colors.red)))
                    : _hasil.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search_off_outlined,
                                    size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 8),
                                Text(
                                  'Produk tidak ditemukan',
                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _hasil.length,
                            padding: const EdgeInsets.only(bottom: 8),
                            itemBuilder: (_, i) => _kartuProduk(_hasil[i]),
                          ),
          ),

          // Banner Keranjang Mengambang di Atas Nav (Figma Screen 02)
          if (_keranjang.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: kPrimary,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: kPrimary.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$_jumlahItem item • ${rupiah(_total)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _tipePembeli == 'umum'
                              ? 'Pembeli Umum (Eceran)'
                              : 'Reseller (Grosir)',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => KeranjangScreen(
                            items: _keranjang,
                            tipeAwal: _tipePembeli == 'umum' ? 'eceran' : 'grosir',
                          ),
                        ),
                      ).then((_) => setState(() {}));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Lihat Keranjang',
                            style: TextStyle(
                              color: kPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 14, color: kPrimary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Floating Bottom Nav
          const KasirBottomNav(currentIndex: 1),
        ],
      ),
    );
  }
}
