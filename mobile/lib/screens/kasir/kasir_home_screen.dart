import 'package:flutter/material.dart';
import 'kasir_screen.dart';
import '../riwayat_screen.dart';
import '../retur_screen.dart';

class KasirHomeScreen extends StatelessWidget {
  const KasirHomeScreen({super.key});

  Widget _menu(BuildContext c, IconData icon, String judul, Widget tujuan) {
    return InkWell(
      onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => tujuan)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Icon(icon, color: Colors.blue, size: 32),
          const SizedBox(width: 16),
          Text(judul, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const Spacer(),
          const Icon(Icons.chevron_right),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beranda Kasir')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _menu(context, Icons.point_of_sale, 'Transaksi', const KasirScreen()),
          _menu(context, Icons.history, 'Riwayat', const RiwayatScreen()),
          _menu(context, Icons.assignment_return, 'Retur', const ReturScreen()),
        ]),
      ),
    );
  }
}