import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/keranjang_provider.dart';
import '../../utils/format.dart';
import 'transaksi_berhasil_screen.dart';

class KeranjangScreen extends StatelessWidget {
  const KeranjangScreen({super.key});

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _konfirmasi(BuildContext context) async {
    final kr = context.read<KeranjangProvider>();
    final err = kr.validasi();
    if (err != null) {
      _snack(context, err);
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi pembayaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipe pembeli: ${kr.tipePembeli}'),
            Text('Metode bayar: ${kr.metodeBayar}'),
            const SizedBox(height: 8),
            Text('Total: ${rp(kr.total)}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Bayar')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    final trx = await kr.bayar();
    if (!context.mounted) return;
    if (trx != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TransaksiBerhasilScreen(transaksi: trx)),
      );
    } else if (kr.error != null) {
      _snack(context, kr.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kr = context.watch<KeranjangProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang')),
      body: Column(
        children: [
          if (kr.loading) const LinearProgressIndicator(),
          Expanded(
            child: kr.items.isEmpty
                ? const Center(child: Text('Keranjang kosong'))
                : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final item in kr.items)
                  Card(
                    child: ListTile(
                      title: Text(item.produk.nama),
                      subtitle: Text(rp(kr.harga(item))),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: kr.loading
                                ? null
                                : () => kr.ubahJumlah(item, -1),
                          ),
                          Text('${item.jumlah}'),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: kr.loading
                                ? null
                                : () {
                              final e = kr.ubahJumlah(item, 1);
                              if (e != null) _snack(context, e);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                const Text('Tipe pembeli'),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'umum', label: Text('Umum')),
                    ButtonSegment(value: 'grosir', label: Text('Grosir')),
                  ],
                  selected: {kr.tipePembeli},
                  onSelectionChanged: (s) => kr.tipePembeli = s.first,
                ),
                const SizedBox(height: 16),
                const Text('Metode bayar'),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'tunai', label: Text('Tunai')),
                    ButtonSegment(value: 'transfer', label: Text('Transfer')),
                  ],
                  selected: {kr.metodeBayar},
                  onSelectionChanged: (s) => kr.metodeBayar = s.first,
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Total\n${rp(kr.total)}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton(
                    onPressed:
                    (kr.items.isEmpty || kr.loading) ? null : () => _konfirmasi(context),
                    child: kr.loading
                        ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Bayar'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}