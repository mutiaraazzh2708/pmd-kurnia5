import 'package:flutter/material.dart';
import '../models/transaksi.dart';
import '../utils/format.dart';

class StrukScreen extends StatelessWidget {
  final Transaksi transaksi;
  const StrukScreen({super.key, required this.transaksi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi Berhasil'), automaticallyImplyLeading: false),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 72),
        const SizedBox(height: 8),
        const Center(child: Text('Transaksi berhasil',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        const Divider(height: 32),
        Text('No: ${transaksi.nomor}'),
        Text('Tanggal: ${tanggal(transaksi.tanggal)}'),
        Text('Tipe pembeli: ${transaksi.tipePembeli}'),
        Text('Metode bayar: ${transaksi.metodeBayar}'),
        const Divider(height: 32),
        ...transaksi.items.map((e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text('${e.nama} x${e.qty}')),
            Text(rupiah(e.harga * e.qty)),
          ]),
        )),
        const Divider(height: 32),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(rupiah(transaksi.total),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ]),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
          child: const Text('Transaksi baru'),
        ),
      ]),
    );
  }
}