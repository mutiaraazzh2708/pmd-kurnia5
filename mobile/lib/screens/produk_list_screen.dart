import 'package:flutter/material.dart';
import '../main.dart';
import '../services/api_service.dart';
import 'produk_form_screen.dart';

class ProdukListScreen extends StatefulWidget {
  const ProdukListScreen({super.key});

  @override
  State<ProdukListScreen> createState() => _ProdukListScreenState();
}

class _ProdukListScreenState extends State<ProdukListScreen> {
  List<dynamic> _produk = [];
  List<dynamic> _filtered = [];
  bool _isLoading = true;
  String _userRole = 'pemilik';
  final TextEditingController _searchController = TextEditingController();
  int _selectedTab = 1;

  @override
  void initState() {
    super.initState();
    _muatData();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _muatData() async {
    setState(() => _isLoading = true);
    final role = await ApiService.getUserRole();
    final data = await ApiService.getProduk();
    if (!mounted) return;
    setState(() {
      if (role != null) _userRole = role;
      _produk = data;
      _filtered = data;
      _isLoading = false;
    });
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _produk
          : _produk.where((p) => p['nama'].toString().toLowerCase().contains(q)).toList();
    });
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

  void _bukaForm([Map<String, dynamic>? produk]) async {
    final refresh = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ProdukFormScreen(produk: produk)),
    );
    if (refresh == true) _muatData();
  }

  void _konfirmasiHapus(int id, String nama) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
              ),
              const SizedBox(height: 16),
              const Text(
                'Hapus produk?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '$nama akan dihapus dan tidak tampil lagi di daftar produk.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      child: const Text('Batal', style: TextStyle(color: Colors.black87)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final ok = await ApiService.deleteProduk(id);
                        if (!mounted) return;
                        if (ok) {
                          _muatData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Produk berhasil dihapus.'),
                              backgroundColor: kPrimary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Gagal menghapus produk.'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Hapus', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRupiah(dynamic angka) {
    final num = double.tryParse(angka.toString()) ?? 0;
    final str = num.toStringAsFixed(0);
    final result = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) result.write('.');
      result.write(str[i]);
      count++;
    }
    return 'Rp ${result.toString().split('').reversed.join()}';
  }

  @override
  Widget build(BuildContext context) {
    final isPemilik = _userRole == 'pemilik';
    return Scaffold(
      backgroundColor: kBackground,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            color: kPrimary,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                Column(
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
                    const SizedBox(height: 2),
                    const Text(
                      'Daftar Produk',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Ketik nama produk',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: kPrimary),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: kPrimary))
                : RefreshIndicator(
                    color: kPrimary,
                    onRefresh: _muatData,
                    child: _filtered.isEmpty
                        ? _buildEmptyState(isPemilik)
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filtered.length,
                            itemBuilder: (ctx, i) => _buildProdukItem(_filtered[i], isPemilik),
                          ),
                  ),
          ),

          // Tambah Produk Button
          if (isPemilik)
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(
                left: 16, right: 16, top: 12,
                bottom: MediaQuery.of(context).padding.bottom + 12,
              ),
              child: SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => _bukaForm(),
                  icon: const Icon(Icons.add, color: kPrimary),
                  label: const Text(
                    'Tambah Produk',
                    style: TextStyle(color: kPrimary, fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
              ),
            ),

          // Bottom Nav
          _buildBottomNav(context),
        ],
      ),
    );
  }

  Widget _buildProdukItem(Map<String, dynamic> p, bool isPemilik) {
    final stok = p['stok'] ?? 0;
    final namaSatuan = p['satuan'] != null ? p['satuan']['nama'] : 'pcs';
    final hargaBeli = _formatRupiah(p['harga_beli'] ?? 0);
    final hargaJual = _formatRupiah(p['harga_jual'] ?? 0);

    return GestureDetector(
      onTap: isPemilik ? () => _bukaForm(Map<String, dynamic>.from(p)) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
        ),
        child: Row(
          children: [
            // Stok Badge
            Container(
              width: 50,
              height: 56,
              decoration: BoxDecoration(
                color: kPrimary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'STOK',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    '$stok',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Nama & Satuan
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p['nama'] ?? '-',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Satuan $namaSatuan',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Harga
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Beli $hargaBeli',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  hargaJual,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            if (isPemilik) ...[
              const SizedBox(width: 8),
              // Tombol Edit yang jelas
              GestureDetector(
                onTap: () => _bukaForm(Map<String, dynamic>.from(p)),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.edit_outlined, color: Colors.blue.shade700, size: 18),
                ),
              ),
              const SizedBox(width: 6),
              // Tombol Hapus
              GestureDetector(
                onTap: () => _konfirmasiHapus(p['id'], p['nama']),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.delete_outline, color: Colors.red.shade600, size: 18),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isPemilik) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
        Center(
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.inventory_2_outlined, size: 40, color: Colors.grey.shade400),
              ),
              const SizedBox(height: 16),
              const Text(
                'Belum ada produk',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 6),
              Text(
                'Tambahkan produk pertama untuk mulai.',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
              if (isPemilik) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _bukaForm(),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Tambah Produk', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context) {
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
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: _buildNavItem(0, Icons.home_outlined, 'Beranda'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: _buildNavItem(1, Icons.inventory_2_outlined, 'Produk')),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedTab == index;
    return AnimatedContainer(
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
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ],
      ),
    );
  }
}
