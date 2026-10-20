import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  // Data tiruan, nanti diganti data API di tugas #18
  final int jumlahProduk = 24;
  final int stokMenipis = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _kartu('Jumlah Produk', '$jumlahProduk', Icons.inventory_2),
            const SizedBox(height: 12),
            _kartu('Stok Menipis', '$stokMenipis', Icons.warning_amber),
          ],
        ),
      ),
    );
  }

  Widget _kartu(String judul, String nilai, IconData ikon) {
    return Card(
      child: ListTile(
        leading: Icon(ikon, size: 36),
        title: Text(judul),
        trailing: Text(nilai,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
    );
  }
}