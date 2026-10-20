import 'package:flutter/material.dart';

class ProdukListScreen extends StatefulWidget {
  const ProdukListScreen({super.key});

  @override
  State<ProdukListScreen> createState() => _ProdukListScreenState();
}

class _ProdukListScreenState extends State<ProdukListScreen> {
  // Data tiruan, nanti diganti data dari API oleh Shandi
  final List<Map<String, dynamic>> _produk = [
    {'nama': 'Gula Pasir', 'satuan': 'kg', 'harga': 15000, 'stok': 50},
    {'nama': 'Minyak Goreng', 'satuan': 'liter', 'harga': 18000, 'stok': 30},
    {'nama': 'Beras', 'satuan': 'kg', 'harga': 13000, 'stok': 100},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Produk')),
      body: _produk.isEmpty
          ? const Center(child: Text('Belum ada produk'))
          : ListView.builder(
        itemCount: _produk.length,
        itemBuilder: (context, index) {
          final p = _produk[index];
          return ListTile(
            title: Text(p['nama']),
            subtitle: Text('Rp ${p['harga']} / ${p['satuan']}'),
            trailing: Text('Stok: ${p['stok']}'),
          );
        },
      ),
    );
  }
}