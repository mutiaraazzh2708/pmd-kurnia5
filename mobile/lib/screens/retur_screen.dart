import 'package:flutter/material.dart';
import '../models/transaksi.dart';
import '../services/kasir_service.dart';
import '../utils/format.dart';

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
  Transaksi? _trx;            // transaksi terpilih (dengan items)
  TransaksiItem? _item;       // produk terpilih
  bool _loading = true;
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

  void _snack(String m, {bool error = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(m), backgroundColor: error ? Colors.red : Colors.green));
  }

  Future<void> _muatTransaksi() async {
    try {
      final d = await KasirService.riwayat('semua');
      if (!mounted) return;
      setState(() => _daftarTrx = d);
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pilihTransaksi(Transaksi? t) async {
    if (t == null) return;
    setState(() {
      _item = null;
      _trx = null;
    });
    try {
      final detail = await KasirService.detail(t.id);
      if (!mounted) return;
      setState(() => _trx = detail);
    } catch (e) {
      _snack(e.toString());
    }
  }

  Future<void> _simpan() async {
    // #55 validasi form (layar 09)
    if (!_formKey.currentState!.validate()) return;

    final ya = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Simpan retur?'),
        content: Text('${_item!.nama} x${_qtyCtrl.text}\nAlasan: ${_alasanCtrl.text}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Simpan')),
        ],
      ),
    );
    if (ya != true) return;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Retur')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          DropdownButtonFormField<Transaksi>(
            decoration: const InputDecoration(
                labelText: 'Transaksi', border: OutlineInputBorder()),
            items: _daftarTrx
                .map((t) => DropdownMenuItem(
                value: t, child: Text('${t.nomor} - ${rupiah(t.total)}')))
                .toList(),
            onChanged: _pilihTransaksi,
            validator: (v) => (_trx == null) ? 'Pilih transaksi' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<TransaksiItem>(
            value: _item,
            decoration: const InputDecoration(
                labelText: 'Produk', border: OutlineInputBorder()),
            items: (_trx?.items ?? [])
                .map((e) => DropdownMenuItem(
                value: e, child: Text('${e.nama} (dibeli ${e.qty})')))
                .toList(),
            onChanged: (v) => setState(() => _item = v),
            validator: (v) => v == null ? 'Pilih produk' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _qtyCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: 'Jumlah retur', border: OutlineInputBorder()),
            validator: (v) {
              final n = int.tryParse(v ?? '');
              if (n == null) return 'Jumlah harus angka';
              if (n < 1) return 'Jumlah minimal 1';
              if (_item != null && n > _item!.qty) {
                return 'Maksimal ${_item!.qty} (jumlah dibeli)';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _alasanCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
                labelText: 'Alasan retur', border: OutlineInputBorder()),
            validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Alasan wajib diisi' : null,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _menyimpan ? null : _simpan,
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: _menyimpan
                ? const SizedBox(height: 20, width: 20,
                child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Simpan retur'),
          ),
        ]),
      ),
    );
  }
}