import 'package:flutter/material.dart';
import '../models/transaksi.dart';
import '../services/kasir_service.dart';
import '../utils/format.dart';

/// US-09 – Halaman Riwayat Transaksi
/// Menampilkan daftar transaksi yang sudah selesai dengan filter periode.
/// Pengguna dapat mengetuk sebuah transaksi untuk melihat detailnya.
class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  String _periode = 'hari_ini';
  late Future<List<Transaksi>> _future;

  @override
  void initState() {
    super.initState();
    _future = KasirService.riwayat(_periode);
  }

  void _muatUlang() {
    setState(() => _future = KasirService.riwayat(_periode));
  }

  // ─── Detail bottom-sheet ──────────────────────────────────────────────────

  void _lihatDetail(Transaksi t) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DetailSheet(transaksiId: t.id),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
            onPressed: _muatUlang,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Filter periode ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'hari_ini', label: Text('Hari ini')),
                ButtonSegment(value: 'minggu_ini', label: Text('Minggu ini')),
                ButtonSegment(value: 'semua', label: Text('Semua')),
              ],
              selected: {_periode},
              onSelectionChanged: (s) {
                setState(() => _periode = s.first);
                _muatUlang();
              },
            ),
          ),

          // ── Daftar transaksi ────────────────────────────────────────────
          Expanded(
            child: FutureBuilder<List<Transaksi>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _ErrorView(
                    pesan: '${snapshot.error}',
                    onRetry: _muatUlang,
                  );
                }
                final data = snapshot.data!;
                if (data.isEmpty) {
                  return const _KosongView();
                }
                return RefreshIndicator(
                  onRefresh: () async => _muatUlang(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: data.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final t = data[i];
                      return _TransaksiCard(
                        transaksi: t,
                        onTap: () => _lihatDetail(t),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widget: kartu transaksi ─────────────────────────────────────────────────

class _TransaksiCard extends StatelessWidget {
  const _TransaksiCard({required this.transaksi, required this.onTap});

  final Transaksi transaksi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = transaksi;

    return Card(
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: cs.primaryContainer,
          child: Icon(Icons.receipt_long, color: cs.onPrimaryContainer),
        ),
        title: Text(
          t.nomor,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(tanggal(t.tanggal)),
            const SizedBox(height: 2),
            Row(
              children: [
                _Chip(label: t.metodeBayar),
                const SizedBox(width: 6),
                _Chip(label: t.tipePembeli),
              ],
            ),
          ],
        ),
        trailing: Text(
          rupiah(t.total),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: cs.primary,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

// ─── Widget: chip kecil ──────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  const _Chip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: cs.onSecondaryContainer),
      ),
    );
  }
}

// ─── Widget: detail bottom-sheet ─────────────────────────────────────────────

class _DetailSheet extends StatelessWidget {
  const _DetailSheet({required this.transaksiId});
  final int transaksiId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Transaksi>(
      future: KasirService.detail(transaksiId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return SizedBox(
            height: 200,
            child: Center(child: Text('${snapshot.error}')),
          );
        }
        final d = snapshot.data!;
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, controller) => SingleChildScrollView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handel
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Nomor & tanggal
                Text(d.nomor,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(tanggal(d.tanggal),
                    style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _Chip(label: d.metodeBayar),
                    const SizedBox(width: 6),
                    _Chip(label: d.tipePembeli),
                  ],
                ),
                const Divider(height: 24),

                // Daftar item
                ...d.items.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(child: Text(e.nama)),
                          Text('x${e.qty}'),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 100,
                            child: Text(
                              rupiah(e.harga * e.qty),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    )),

                const Divider(height: 24),

                // Ringkasan pembayaran
                _RingkasanBaris(label: 'Total', nilai: rupiah(d.total), bold: true),
                if (d.bayar > 0) ...[
                  _RingkasanBaris(label: 'Bayar', nilai: rupiah(d.bayar)),
                  _RingkasanBaris(
                      label: 'Kembalian', nilai: rupiah(d.kembalian)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Widget: baris ringkasan ─────────────────────────────────────────────────

class _RingkasanBaris extends StatelessWidget {
  const _RingkasanBaris(
      {required this.label, required this.nilai, this.bold = false});
  final String label;
  final String nilai;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontSize: bold ? 15 : 14,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(nilai, style: style),
        ],
      ),
    );
  }
}

// ─── Widget: state kosong ────────────────────────────────────────────────────

class _KosongView extends StatelessWidget {
  const _KosongView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 72, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text('Belum ada transaksi',
              style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

// ─── Widget: state error ─────────────────────────────────────────────────────

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
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}