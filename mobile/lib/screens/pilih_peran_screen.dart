import 'package:flutter/material.dart';
import '../main.dart';
import 'login_screen.dart';

class PilihPeranScreen extends StatelessWidget {
  const PilihPeranScreen({super.key});

  static const List<Map<String, dynamic>> _peranList = [
    {
      'role': 'pemilik',
      'label': 'Pemilik',
      'deskripsi': 'Memantau dan mengelola toko',
      'icon': Icons.store_outlined,
    },
    {
      'role': 'kasir',
      'label': 'Kasir',
      'deskripsi': 'Melayani dan mencatat penjualan',
      'icon': Icons.receipt_long_outlined,
    },
    {
      'role': 'karyawan_toko',
      'label': 'Karyawan Toko',
      'deskripsi': 'Mengurus stok dan barang masuk',
      'icon': Icons.inventory_2_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimary,
      body: Stack(
        children: [
          // Dekorasi lingkaran background
          Positioned(
            top: -80,
            right: -80,
            child: _buildCircle(220, Colors.white.withOpacity(0.04)),
          ),
          Positioned(
            top: 60,
            right: -40,
            child: _buildCircle(140, Colors.white.withOpacity(0.04)),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // Ikon Toko
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.storefront_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Judul
                  const Text(
                    'Toko Grosir PMD\nKurnia 5',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sistem Penjualan dan Stok',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Label
                  Text(
                    'MASUK SEBAGAI SIAPA?',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Daftar Peran
                  ..._peranList.map((peran) => _buildPeranCard(context, peran)),

                  const Spacer(),

                  // Footer
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Text(
                      'Setelah memilih, kamu diminta memasukkan username dan password.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeranCard(BuildContext context, Map<String, dynamic> peran) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LoginScreen(
              role: peran['role'],
              roleLabel: peran['label'],
              roleDeskripsi: peran['deskripsi'],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(peran['icon'] as IconData, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    peran['label'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    peran['deskripsi'],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.5), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
