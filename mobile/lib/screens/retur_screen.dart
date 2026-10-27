import 'package:flutter/material.dart';
import '../models/transaksi.dart';
import '../services/kasir_service.dart';
import '../utils/format.dart';

/// US-10 – Layar Retur Produk
/// Kasir memilih transaksi → memilih produk → mengisi jumlah & alasan → kirim ke API.
class ReturScreen extends StatefulWidget {
  const ReturScreen({super.key});

  @override
  State<ReturScreen> createState() => _ReturScreenState();
}

class _ReturScreenState extends State<ReturScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qtyCtrl = TextEditingController();
  final _alasanCtrl = TextEditingController();

  List<Transaksi> _daftarTrx = [];
  Transaksi? _trx;          // transaksi terpilih (dengan items lengkap)
  TransaksiItem? _item;     // produk terpilih

  bool _loadingTrx = true;
  bool _loadingDetail = false;
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    _muatTransaksi();
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _alasanCtrl.dispose();
    super.dispose();
  }

  // ─── Snackbar helper ─────────────────────────────────────────────────────

  void _snack(String m, {bool error = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(m),
      backgroundColor: error ? Colors.red : Colors.green,
    ));
  }

  // ─── Muat daftar semua transaksi ─────────────────────────────────────────

  Future<void> _muatTransaksi() async {
    setState(() => _loadingTrx = true);
    try {
      final data = await KasirService.riwayat('semua');
      if (!mounted) return;
      setState(() => _daftarTrx = data);
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _loadingTrx = false);
    }
  }

  // ─── Muat detail transaksi yang dipilih (untuk mendapatkan items) ─────────

  Future<void> _pilihTransaksi(Transaksi? t) async {
    if (t == null) return;
    setState(() {
      _trx = null;
      _item = null;
      _loadingDetail = true;
    });
    try {
      final detail = await KasirService.detail(t.id);
      if (!mounted) return;
      setState(() => _trx = detail);
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _loadingDetail = false);
    }
  }

  // ─── Simpan retur ke API ──────────────────────────────────────────────────

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Retur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Produk   : ${_item!.nama}'),
            Text('Jumlah   : ${_qtyCtrl.text}'),
            Text('Alasan   : ${_alasanCtrl.text}'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Simpan')),
        ],
      ),
    );
    if (konfirmasi != true) return;

    setState(() => _menyimpan = true);
    try {
      await KasirService.simpanRetur(
        transaksiId: _trx!.id,
        productId: _item!.productId,
        qty: int.parse(_qtyCtrl.text),
        alasan: _alasanCtrl.text.trim(),
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

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Retur Produk')),
      body: _loadingTrx
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ── Pilih transaksi ──────────────────────────────────────
                  DropdownButtonFormField<Transaksi>(
                    decoration: const InputDecoration(
                      labelText: 'Nomor Transaksi',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.receipt_long),
                    ),
                    isExpanded: true,
                    items: _daftarTrx
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child:
                                  Text('${t.nomor}  –  ${rupiah(t.total)}'),
                            ))
                        .toList(),
                    onChanged: _pilihTransaksi,
                    validator: (_) =>
                        _trx == null ? 'Pilih transaksi terlebih dahulu' : null,
                  ),

                  const SizedBox(height: 16),

                  // ── Loading detail ───────────────────────────────────────
                  if (_loadingDetail)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  // ── Pilih produk ─────────────────────────────────────────
                  DropdownButtonFormField<TransaksiItem>(
                    value: _item,
                    decoration: const InputDecoration(
                      labelText: 'Produk',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.inventory_2_outlined),
                    ),
                    isExpanded: true,
                    items: (_trx?.items ?? [])
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text('${e.nama}  (dibeli ${e.qty})'),
                            ))
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        _item = v;
                        _qtyCtrl.clear();
                      });
                    },
                    validator: (v) =>
                        v == null ? 'Pilih produk yang diretur' : null,
                  ),

                  const SizedBox(height: 16),

                  // ── Jumlah retur ─────────────────────────────────────────
                  TextFormField(
                    controller: _qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Jumlah retur',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.numbers),
                      helperText: _item != null
                          ? 'Maksimal ${_item!.qty} (sesuai pembelian)'
                          : null,
                    ),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null) return 'Jumlah harus berupa angka';
                      if (n < 1) return 'Jumlah minimal 1';
                      if (_item != null && n > _item!.qty) {
                        return 'Maksimal ${_item!.qty} (sesuai jumlah dibeli)';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // ── Alasan retur ─────────────────────────────────────────
                  TextFormField(
                    controller: _alasanCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Alasan retur',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.comment_outlined),
                      alignLabelWithHint: true,
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Alasan wajib diisi'
                            : null,
                  ),

                  const SizedBox(height: 28),

                  // ── Tombol simpan ────────────────────────────────────────
                  FilledButton.icon(
                    onPressed: _menyimpan ? null : _simpan,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    icon: _menyimpan
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child:
                                CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check_circle_outline),
                    label: Text(_menyimpan ? 'Menyimpan…' : 'Simpan Retur'),
                  ),
                ],
              ),
            ),
    );
  }
}