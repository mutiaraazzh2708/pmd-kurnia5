import 'package:flutter/material.dart';
import '../models/transaksi.dart';
import '../services/kasir_service.dart';
import '../utils/format.dart';
import '../widgets/kasir_bottom_nav.dart';

class ReturScreen extends StatefulWidget {
  final Transaksi? transaksiAwal;
  const ReturScreen({super.key, this.transaksiAwal});

  @override
  State<ReturScreen> createState() => _ReturScreenState();
}

class _ReturScreenState extends State<ReturScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qtyCtrl = TextEditingController(text: '1');
  String? _alasanTerpilih = 'Barang rusak';

  List<Transaksi> _daftarTrx = [];
  Transaksi? _trx;
  TransaksiItem? _item;

  bool _loadingTrx = true;
  bool _loadingDetail = false;
  bool _menyimpan = false;

  static const List<String> _daftarAlasan = [
    'Barang rusak',
    'Kadaluarsa',
    'Salah produk',
    'Kemasan bocor / cacat',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _muatTransaksi();
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  void _snack(String m, {bool error = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(m),
      backgroundColor: error ? Colors.red : Colors.green,
    ));
  }

  Future<void> _muatTransaksi() async {
    setState(() => _loadingTrx = true);
    try {
      final data = await KasirService.riwayat('semua');
      if (!mounted) return;
      setState(() {
        _daftarTrx = data;
        if (widget.transaksiAwal != null) {
          final target = data.firstWhere(
            (t) => t.id == widget.transaksiAwal!.id,
            orElse: () => widget.transaksiAwal!,
          );
          _pilihTransaksi(target);
        } else if (data.isNotEmpty) {
          _pilihTransaksi(data.first);
        }
      });
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _loadingTrx = false);
    }
  }

  Future<void> _pilihTransaksi(Transaksi? t) async {
    if (t == null) return;
    setState(() {
      _trx = t;
      _item = null;
      _loadingDetail = true;
    });
    try {
      final detail = await KasirService.detail(t.id);
      if (!mounted) return;
      setState(() {
        _trx = detail;
        if (detail.items.isNotEmpty) {
          _item = detail.items.first;
        }
      });
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _loadingDetail = false);
    }
  }

  int get _nilaiRetur {
    if (_item == null) return 0;
    final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 0;
    return _item!.harga * qty;
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    if (_trx == null) {
      _snack('Transaksi wajib dipilih');
      return;
    }
    if (_item == null) {
      _snack('Pilih produk yang akan diretur');
      return;
    }

    setState(() => _menyimpan = true);
    try {
      await KasirService.simpanRetur(
        transaksiId: _trx!.id,
        productId: _item!.productId,
        qty: int.parse(_qtyCtrl.text.trim()),
        alasan: _alasanTerpilih ?? 'Barang rusak',
      );
      if (!mounted) return;
      _snack('Retur berhasil disimpan', error: false);
      Navigator.pop(context);
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _menyimpan = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const kPrimary = Color(0xFF1B3252);
    const kBg = Color(0xFFF4F6F9);

    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          // Header curved navy
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: kPrimary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KASIR',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Retur Barang',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Form Retur
          Expanded(
            child: _loadingTrx
                ? const Center(child: CircularProgressIndicator(color: kPrimary))
                : Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        // Label TRANSAKSI
                        _label('TRANSAKSI'),
                        DropdownButtonFormField<Transaksi>(
                          value: _trx != null && _daftarTrx.any((t) => t.id == _trx!.id)
                              ? _daftarTrx.firstWhere((t) => t.id == _trx!.id)
                              : null,
                          isExpanded: true,
                          decoration: _inputDecoration('Pilih transaksi'),
                          items: _daftarTrx
                              .map((t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(
                                      '${t.nomor} – ${tanggal(t.tanggal)}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ))
                              .toList(),
                          onChanged: _pilihTransaksi,
                          validator: (_) =>
                              _trx == null ? 'Transaksi wajib dipilih' : null,
                        ),

                        const SizedBox(height: 16),

                        if (_loadingDetail)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2, color: kPrimary),
                            ),
                          ),

                        // Label PRODUK
                        _label('PRODUK'),
                        DropdownButtonFormField<TransaksiItem>(
                          value: (_trx?.items != null && _trx!.items.contains(_item)) ? _item : null,
                          isExpanded: true,
                          decoration: _inputDecoration('Pilih produk'),
                          items: (_trx?.items ?? [])
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(
                                      '${e.nama.isNotEmpty ? e.nama : "Produk #${e.productId}"} (dibeli ${e.qty})',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            setState(() {
                              _item = v;
                              if (v != null) {
                                _qtyCtrl.text = '1';
                              }
                            });
                          },
                          validator: (v) =>
                              v == null ? 'Pilih produk yang diretur' : null,
                        ),

                        const SizedBox(height: 16),

                        // Label JUMLAH RETUR
                        _label('JUMLAH RETUR'),
                        TextFormField(
                          controller: _qtyCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Jumlah retur').copyWith(
                            helperText: _item != null
                                ? 'Maksimal ${_item!.qty} (sesuai pembelian)'
                                : null,
                          ),
                          onChanged: (_) => setState(() {}),
                          validator: (v) {
                            final n = int.tryParse(v ?? '');
                            if (n == null) return 'Jumlah harus berupa angka';
                            if (n < 1) return 'Jumlah harus lebih dari 0';
                            if (_item != null && n > _item!.qty) {
                              return 'Jumlah melebihi pembelian (${_item!.qty})';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Label ALASAN RETUR
                        _label('ALASAN RETUR'),
                        DropdownButtonFormField<String>(
                          value: _alasanTerpilih,
                          isExpanded: true,
                          decoration: _inputDecoration('Pilih alasan retur'),
                          items: _daftarAlasan
                              .map((a) => DropdownMenuItem(
                                    value: a,
                                    child: Text(a, style: const TextStyle(fontSize: 14)),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _alasanTerpilih = v),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Alasan retur wajib dipilih' : null,
                        ),

                        const SizedBox(height: 20),

                        // Label NILAI RETUR
                        _label('NILAI RETUR'),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEBF3FC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFD4E6FA)),
                          ),
                          child: Text(
                            rupiah(_nilaiRetur),
                            style: const TextStyle(
                              color: kPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Tombol Simpan Retur
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _menyimpan ? null : _simpan,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _menyimpan
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text(
                                    'Simpan Retur',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Tombol Batal
                        SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: kPrimary,
                              side: const BorderSide(color: kPrimary, width: 1.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Batal',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
          ),

          // Floating Bottom Nav
          const KasirBottomNav(currentIndex: 1),
        ],
      ),
    );
  }

  Widget _label(String text) {
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

  InputDecoration _inputDecoration(String hint) {
    const kPrimary = Color(0xFF1B3252);
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kPrimary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
