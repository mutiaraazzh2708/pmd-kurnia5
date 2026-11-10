import 'package:flutter/material.dart';
import '../main.dart';
import '../services/api_service.dart';

class ProdukFormScreen extends StatefulWidget {
  final Map<String, dynamic>? produk;
  const ProdukFormScreen({super.key, this.produk});

  @override
  State<ProdukFormScreen> createState() => _ProdukFormScreenState();
}

class _ProdukFormScreenState extends State<ProdukFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _satuanDasarController;
  late TextEditingController _hargaBeliController;
  late TextEditingController _hargaJualController;
  late TextEditingController _stokController;

  bool _isLoading = false;
  String _userRole = 'pemilik';

  bool get isEdit => widget.produk != null;

  @override
  void initState() {
    super.initState();
    final p = widget.produk;
    _namaController = TextEditingController(text: p?['nama'] ?? '');
    _satuanDasarController = TextEditingController(
      text: p?['satuan_dasar'] ?? (p?['satuan'] != null ? p!['satuan']['nama'] : 'eceran'),
    );
    _hargaBeliController = TextEditingController(
        text: p?['harga_beli'] != null ? _angkaBulat(p!['harga_beli']) : '');
    _hargaJualController = TextEditingController(
        text: p?['harga_jual'] != null ? _angkaBulat(p!['harga_jual']) : '');
    _stokController = TextEditingController(
        text: p?['stok'] != null ? p!['stok'].toString() : '0');
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await ApiService.getUserRole();
    if (mounted && role != null) setState(() => _userRole = role);
  }

  String _angkaBulat(dynamic val) {
    final d = double.tryParse(val.toString()) ?? 0;
    return d.toStringAsFixed(0);
  }

  String get _roleLabel {
    switch (_userRole) {
      case 'kasir': return 'KASIR';
      case 'karyawan_toko': return 'KARYAWAN TOKO';
      default: return 'PEMILIK';
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _satuanDasarController.dispose();
    _hargaBeliController.dispose();
    _hargaJualController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  void _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final nama = _namaController.text.trim();
    final satuanDasar = _satuanDasarController.text.trim();
    final hargaBeli = double.tryParse(_hargaBeliController.text.trim()) ?? 0;
    final hargaJual = double.tryParse(_hargaJualController.text.trim()) ?? 0;
    final stok = int.tryParse(_stokController.text.trim()) ?? 0;

    Map<String, dynamic> result;
    if (isEdit) {
      result = await ApiService.updateProduk(
        id: widget.produk!['id'],
        nama: nama,
        satuanDasar: satuanDasar,
        hargaBeli: hargaBeli,
        hargaJual: hargaJual,
        stok: stok,
      );
    } else {
      result = await ApiService.tambahProduk(
        nama: nama,
        satuanDasar: satuanDasar,
        hargaBeli: hargaBeli,
        hargaJual: hargaJual,
        stokAwal: stok,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success']) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? 'Gagal menyimpan produk.'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  void _hapusProduk() {
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
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
              ),
              const SizedBox(height: 16),
              const Text('Hapus produk?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                '${widget.produk!['nama']} akan dihapus dan tidak tampil lagi di daftar produk.',
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      child: const Text('Batal',
                          style: TextStyle(color: Colors.black87)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final ok =
                            await ApiService.deleteProduk(widget.produk!['id']);
                        if (!mounted) return;
                        if (ok) {
                          Navigator.pop(context, true);
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Hapus',
                          style: TextStyle(color: Colors.white)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20, right: 20, bottom: 20,
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
                    Text(
                      isEdit ? 'Edit Produk' : 'Tambah Produk',
                      style: const TextStyle(
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

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // NAMA PRODUK
                    _buildLabel('NAMA PRODUK'),
                    TextFormField(
                      controller: _namaController,
                      decoration: _inputDecoration(
                          hint: isEdit ? '' : 'Contoh: Minyak Goreng 2 L'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Nama produk wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // SATUAN DASAR (Sesuai Figma: teks input mis. 'eceran')
                    _buildLabel('SATUAN DASAR'),
                    TextFormField(
                      controller: _satuanDasarController,
                      decoration: _inputDecoration(
                          hint: 'Contoh: eceran'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Satuan dasar wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // HARGA BELI
                    _buildLabel('HARGA BELI'),
                    TextFormField(
                      controller: _hargaBeliController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(hint: 'Rp'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Harga beli wajib diisi';
                        }
                        if (double.tryParse(v.trim()) == null) {
                          return 'Harga beli harus berupa angka';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // HARGA JUAL
                    _buildLabel('HARGA JUAL'),
                    TextFormField(
                      controller: _hargaJualController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(hint: 'Rp'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Harga jual wajib diisi';
                        }
                        if (double.tryParse(v.trim()) == null) {
                          return 'Harga jual harus berupa angka';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // STOK AWAL
                    _buildLabel('STOK AWAL'),
                    TextFormField(
                      controller: _stokController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(hint: '0'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Stok wajib diisi';
                        }
                        if (int.tryParse(v.trim()) == null) {
                          return 'Stok harus berupa angka bulat';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _simpan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                isEdit ? 'Simpan Perubahan' : 'Simpan',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tombol Hapus Produk (hanya di mode Edit)
                    if (isEdit)
                      OutlinedButton.icon(
                        onPressed: _hapusProduk,
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red, size: 18),
                        label: const Text('Hapus Produk',
                            style: TextStyle(
                                color: Colors.red, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          side: const BorderSide(color: Colors.red),
                        ),
                      )
                    // Tombol Batal (hanya di mode Tambah)
                    else
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          side: BorderSide(color: Colors.grey.shade400),
                        ),
                        child: const Text('Batal',
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                                fontSize: 16)),
                      ),

                    const SizedBox(height: 24),
                  ],
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String hint = ''}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kPrimary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
        top: 8, left: 24, right: 24,
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: _navItem(0, Icons.home_outlined, 'Beranda', false),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: _navItem(1, Icons.inventory_2_outlined, 'Produk', true)),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label, bool isSelected) {
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
