import 'package:flutter/material.dart';
import '../main.dart';
import '../services/api_service.dart';
import 'pilih_peran_screen.dart';
import 'produk_list_screen.dart';
import 'riwayat_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  String _userName = 'Pengguna';
  String _userRole = 'pemilik';
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    final name = await ApiService.getUserName();
    final role = await ApiService.getUserRole();
    if (!mounted) return;
    setState(() {
      if (name != null) _userName = name;
      if (role != null) _userRole = role;
      _isLoading = false;
    });
  }

  void _logout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const PilihPeranScreen()),
      (route) => false,
    );
  }

  String get _roleLabel {
    switch (_userRole) {
      case 'kasir':
        return 'KASIR';
      case 'karyawan_toko':
        return 'KARYAWAN TOKO';
      default:
        return 'PEMILIK';
    }
  }

  String get _sapaanNama {
    if (_userName.toLowerCase().contains('pemilik')) return 'Pemilik';
    if (_userName.toLowerCase().contains('kasir')) return 'Kasir';
    if (_userName.toLowerCase().contains('karyawan')) return 'Karyawan Toko';
    return _userName;
  }

  List<Map<String, dynamic>> get _menuItems {
    switch (_userRole) {
      case 'kasir':
        return [
          {'icon': Icons.receipt_long_outlined, 'label': 'Transaksi', 'sub': 'Catat penjualan', 'active': true, 'route': 'transaksi'},
          {'icon': Icons.access_time_outlined, 'label': 'Riwayat', 'sub': 'Lihat transaksi', 'active': true, 'route': 'riwayat'},
          {'icon': Icons.assignment_return_outlined, 'label': 'Retur', 'sub': 'Catat pengembalian', 'active': true, 'route': 'retur'},
        ];
      case 'karyawan_toko':
        return [
          {'icon': Icons.inventory_2_outlined, 'label': 'Produk', 'sub': 'Lihat daftar produk', 'active': true, 'route': 'produk'},
          {'icon': Icons.layers_outlined, 'label': 'Stok', 'sub': 'Belum tersedia', 'active': false, 'route': null},
          {'icon': Icons.input_outlined, 'label': 'Barang Masuk', 'sub': 'Belum tersedia', 'active': false, 'route': null},
          {'icon': Icons.swap_horiz_outlined, 'label': 'Mutasi', 'sub': 'Belum tersedia', 'active': false, 'route': null},
          {'icon': Icons.warehouse_outlined, 'label': 'Gudang', 'sub': 'Belum tersedia', 'active': false, 'route': null},
        ];
      default: // pemilik
        return [
          {'icon': Icons.inventory_2_outlined, 'label': 'Produk', 'sub': 'Tambah, lihat, ubah, hapus', 'active': true, 'route': 'produk'},
          {'icon': Icons.access_time_outlined, 'label': 'Riwayat Transaksi', 'sub': 'Pantau penjualan', 'active': true, 'route': 'riwayat'},
          {'icon': Icons.layers_outlined, 'label': 'Stok', 'sub': 'Belum tersedia', 'active': false, 'route': null},
          {'icon': Icons.bar_chart_outlined, 'label': 'Laporan', 'sub': 'Belum tersedia', 'active': false, 'route': null},
        ];
    }
  }

  void _onMenuTap(Map<String, dynamic> menu) {
    if (menu['active'] != true) return;
    final route = menu['route'];
    if (route == 'produk') {
      setState(() => _selectedTab = 1);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProdukListScreen()),
      ).then((_) => setState(() => _selectedTab = 0));
    } else if (route == 'riwayat') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const RiwayatScreen(showBottomNav: false),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : Column(
              children: [
                // Header
                _buildHeader(),

                // Konten
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Info Card
                        _buildInfoCard(),
                        const SizedBox(height: 20),

                        // Grid Menu
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.1,
                          children: _menuItems
                              .map((menu) => _buildMenuCard(menu))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Navigation
                _buildBottomNav(),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      decoration: const BoxDecoration(
        color: kPrimary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BERANDA',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Halo, $_sapaanNama',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kPrimaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _roleLabel,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Toko Grosir PMD Kurnia 5',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Sistem Penjualan dan Stok',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(Map<String, dynamic> menu) {
    final isActive = menu['active'] as bool;
    return GestureDetector(
      onTap: () => _onMenuTap(menu),
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? kPrimary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? null
              : Border.all(
                  color: Colors.grey.shade300,
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
          boxShadow: isActive
              ? [BoxShadow(color: kPrimary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
              : null,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive ? Colors.white.withOpacity(0.2) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                menu['icon'] as IconData,
                color: isActive ? Colors.white : Colors.grey.shade500,
                size: 22,
              ),
            ),
            const Spacer(),
            Text(
              menu['label'],
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              menu['sub'],
              style: TextStyle(
                color: isActive ? Colors.white70 : Colors.grey.shade500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -2))],
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 8,
        top: 8,
        left: 24,
        right: 24,
      ),
      child: Row(
        children: [
          Expanded(child: _buildNavItem(0, Icons.home_outlined, 'Beranda')),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProdukListScreen()),
                );
              },
              child: _buildNavItem(1, Icons.inventory_2_outlined, 'Produk'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? kPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade500, size: 20),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
