import 'package:flutter/material.dart';

import '../../models/transaksi.dart';
import '../../utils/format.dart';

class TransaksiBerhasilScreen extends StatelessWidget {
  final Transaksi transaksi;
  const TransaksiBerhasilScreen({super.key, required this.transaksi});

  @override
  Widget build(BuildContext context) {
    final t = transaksi;
    final w = t.createdAt;
    final waktu = w == null
        ? '-'
        : '${w.day.toString().padLeft(2, '0')}/${w.month.toString().padLeft(2, '0')}/${w.year} '
        '${w.hour.toString().padLeft(2, '0')}:${w.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi Berhasil'), automaticallyImplyLeading: false),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 72),
          const SizedBox(height: 8),
          const Center(
              child: Text('Transaksi berhasil disimpan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Struk #${t.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(waktu),
                  Text('Tipe pembeli: ${t.tipePembeli}'),
                  Text('Metode bayar: ${t.metodeBayar}'),
                  const Divider(height: 24),
                  for (final d in t.detail)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Expanded(child: Text('${d.nama}\n${d.jumlah} x ${rp(d.harga)}')),
                          Text(rp(d.subtotal)),
                        ],
                      ),
                    ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Expanded(
                          child: Text('Total',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      Text(rp(t.total),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Transaksi baru'),
          ),
        ],
      ),
    );
  }
}