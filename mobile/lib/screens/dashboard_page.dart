import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'kasir/kasir_home_screen.dart';
import 'login_screen.dart';
import 'produk_list_screen.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _jumlahProduk = 0;
  int _stokMenipis = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    setState(() => _loading = true);
    final produkList = await ApiService.getProduk();
    if (!mounted) return;

    int menipis = 0;
    for (final p in produkList) {
      final stok = int.tryParse(p['stok']?.toString() ?? '0') ?? 0;
      if (stok <= 10) {
        menipis++;
      }
    }

    setState(() {
      _jumlahProduk = produkList.length;
      _stokMenipis = menipis;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan',
            onPressed: _muatData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await ApiService.clearToken();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _muatData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  _kartu(
                    'Jumlah Produk',
                    '$_jumlahProduk',
                    Icons.inventory_2,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProdukListScreen()),
                      ).then((_) => _muatData());
                    },
                  ),
                  const SizedBox(height: 12),
                  _kartu(
                    'Stok Menipis (<= 10)',
                    '$_stokMenipis',
                    Icons.warning_amber,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.point_of_sale, size: 36, color: Colors.blue),
                      title: const Text('Menu Kasir & Transaksi'),
                      subtitle: const Text('Transaksi, riwayat, dan retur'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const KasirHomeScreen()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _kartu(String judul, String nilai, IconData ikon, {VoidCallback? onTap}) {
    return Card(
      child: ListTile(
        leading: Icon(ikon, size: 36),
        title: Text(judul),
        trailing: Text(
          nilai,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        onTap: onTap,
      ),
    );
  }
}
