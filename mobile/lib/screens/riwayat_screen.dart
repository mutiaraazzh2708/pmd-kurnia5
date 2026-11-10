import 'package:flutter/material.dart';
import '../models/transaksi.dart';
import '../services/kasir_service.dart';
import '../utils/format.dart';
import '../widgets/kasir_bottom_nav.dart';
import 'retur_screen.dart';

class RiwayatScreen extends StatefulWidget {
  /// [showBottomNav] = false saat dibuka dari dashboard pemilik
  final bool showBottomNav;
  const RiwayatScreen({super.key, this.showBottomNav = true});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  String _periode = 'hari_ini';
  late Future<List<Transaksi>> _future;
  final _searchCtrl = TextEditingController();
  String _filterQuery = '';

  @override
  void initState() {
    super.initState();
    _future = KasirService.riwayat(_periode);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _muatUlang() {
    setState(() => _future = KasirService.riwayat(_periode));
  }

  void _lihatDetail(Transaksi t) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _DetailSheet(
        transaksiId: t.id,
        bolehRetur: widget.showBottomNav, // kasir = true, pemilik = false
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
                    if (!widget.showBottomNav)
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 16),
                            SizedBox(width: 4),
                            Text('Kembali', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          ],
                        ),
                      ),
                    if (!widget.showBottomNav) const SizedBox(height: 8),
                    Text(
                      widget.showBottomNav ? 'KASIR' : 'PEMILIK',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Riwayat Transaksi',
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

          // Search Box Pill Sesuai Figma
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _filterQuery = v.trim().toLowerCase()),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 22),
                  hintText: 'Ketik nama produk',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // Filter Periode Pills Sesuai Figma (Semua / Hari ini / Minggu ini)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              height: 42,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE5EDF6),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  _filterPill('semua', 'Semua'),
                  _filterPill('hari_ini', 'Hari ini'),
                  _filterPill('minggu_ini', 'Minggu ini'),
                ],
              ),
            ),
          ),

          // Daftar Riwayat Transaksi
          Expanded(
            child: FutureBuilder<List<Transaksi>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator(color: kPrimary));
                }
                if (snapshot.hasError) {
                  return _ErrorView(pesan: '${snapshot.error}', onRetry: _muatUlang);
                }
                var list = snapshot.data ?? [];
                if (_filterQuery.isNotEmpty) {
                  list = list.where((t) {
                    final cocokItem = t.items.any((i) => i.nama.toLowerCase().contains(_filterQuery));
                    final cocokTipe = t.tipePembeli.toLowerCase().contains(_filterQuery);
                    final cocokMetode = t.metodeBayar.toLowerCase().contains(_filterQuery);
                    return cocokItem || cocokTipe || cocokMetode;
                  }).toList();
                }

                if (list.isEmpty) {
                  return const _KosongView();
                }

                return RefreshIndicator(
                  onRefresh: () async => _muatUlang(),
                  color: kPrimary,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: list.length,
                    itemBuilder: (_, i) => _TransaksiCard(
                      transaksi: list[i],
                      onTap: () => _lihatDetail(list[i]),
                    ),
                  ),
                );
              },
            ),
          ),

          // Floating Bottom Nav — hanya tampil jika kasir
          if (widget.showBottomNav) const KasirBottomNav(currentIndex: 2),
        ],
      ),
    );
  }

  Widget _filterPill(String key, String label) {
    const kPrimary = Color(0xFF1B3252);
    final isActive = _periode == key;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _periode = key);
          _muatUlang();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isActive ? kPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : kPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Widget: Kartu Riwayat Transaksi Sesuai Figma 07 ─────────────────────────

class _TransaksiCard extends StatelessWidget {
  const _TransaksiCard({required this.transaksi, required this.onTap});

  final Transaksi transaksi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const kPrimary = Color(0xFF1B3252);
    final t = transaksi;
    final jumlahItem = t.items.fold<int>(0, (sum, i) => sum + i.qty);
    final itemCount = jumlahItem > 0 ? jumlahItem : (t.items.isNotEmpty ? t.items.length : 1);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Badge Kotak Biru ITEM X
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
                        'ITEM',
                        style: TextStyle(
                          color: kPrimary,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$itemCount',
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

                // Info: Tipe, Metode & Tanggal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${t.tipePembeli == 'reseller' ? 'Reseller' : 'Umum'}, ${t.metodeBayar.toUpperCase()}',
                        style: const TextStyle(
                          color: kPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tanggal(t.tanggal),
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Total Harga
                Text(
                  rupiah(t.total),
                  style: const TextStyle(
                    color: kPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Widget: Detail Bottom Sheet ─────────────────────────────────────────────

class _DetailSheet extends StatelessWidget {
  const _DetailSheet({required this.transaksiId, this.bolehRetur = true});
  final int transaksiId;
  final bool bolehRetur;

  @override
  Widget build(BuildContext context) {
    const kPrimary = Color(0xFF1B3252);

    return FutureBuilder<Transaksi>(
      future: KasirService.detail(transaksiId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 220,
            child: Center(child: CircularProgressIndicator(color: kPrimary)),
          );
        }
        if (snapshot.hasError) {
          return SizedBox(
            height: 220,
            child: Center(
              child: Text('${snapshot.error}', style: const TextStyle(color: Colors.red)),
            ),
          );
        }

        final d = snapshot.data!;
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, controller) => SingleChildScrollView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  d.nomor,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${tanggal(d.tanggal)} | ${d.tipePembeli} | ${d.metodeBayar}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const Divider(height: 28),

                // Daftar Item
                for (final e in d.items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${e.nama.isNotEmpty ? e.nama : "Produk #${e.productId}"} x${e.qty}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        Text(
                          rupiah(e.harga * e.qty),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                const Divider(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimary),
                    ),
                    Text(
                      rupiah(d.total),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: kPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (bolehRetur)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReturScreen(transaksiAwal: d),
                          ),
                        );
                      },
                      icon: const Icon(Icons.assignment_return_outlined, size: 20),
                      label: const Text(
                        'Retur Transaksi Ini',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _KosongView extends StatelessWidget {
  const _KosongView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'Belum ada transaksi di periode ini',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.pesan, required this.onRetry});
  final String pesan;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(pesan, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
