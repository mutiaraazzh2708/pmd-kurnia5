import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/produk.dart';
import '../../providers/keranjang_provider.dart';
import '../../services/api_service.dart';
import '../../utils/format.dart';
import 'keranjang_screen.dart';

class KasirScreen extends StatelessWidget {
  const KasirScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => KeranjangProvider(),
      child: const _KasirView(),
    );
  }
}

class _KasirView extends StatefulWidget {
  const _KasirView();

  @override
  State<_KasirView> createState() => _KasirViewState();
}

class _KasirViewState extends State<_KasirView> {
  final _cari = TextEditingController();
  Timer? _debounce;
  List<Produk> _hasil = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _muat('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _cari.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _muat(v.trim()));
  }

  Future<void> _muat(String kata) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiService.cariProduk(kata);
      if (!mounted || _cari.text.trim() != kata) return; // abaikan hasil usang
      setState(() => _hasil = data);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _tambah(Produk p) {
    final err = context.read<KeranjangProvider>().tambah(p);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(err ?? '${p.nama} ditambahkan'),
        duration: const Duration(seconds: 1),
      ));
  }

  void _bukaKeranjang() {
    final kr = context.read<KeranjangProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: kr,
          child: const KeranjangScreen(),
        ),
      ),
    ).then((_) => _muat(_cari.text.trim())); // segarkan stok
  }

  @override
  Widget build(BuildContext context) {
    final kr = context.watch<KeranjangProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Kasir')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _cari,
              onChanged: _onChanged,
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          Expanded(child: _daftar()),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: kr.items.isEmpty ? null : _bukaKeranjang,
            child: Text(kr.items.isEmpty
                ? 'Keranjang kosong'
                : 'Lihat keranjang (${kr.jumlahItem}) • ${rp(kr.total)}'),
          ),
        ),
      ),
    );
  }

  Widget _daftar() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            TextButton(
                onPressed: () => _muat(_cari.text.trim()),
                child: const Text('Coba lagi')),
          ],
        ),
      );
    }
    if (!_loading && _hasil.isEmpty) {
      return const Center(child: Text('Produk tidak ditemukan'));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _hasil.length,
      itemBuilder: (_, i) {
        final p = _hasil[i];
        final habis = p.stok <= 0;
        return Card(
          child: ListTile(
            enabled: !habis,
            title: Text(p.nama),
            subtitle: Text('Stok ${p.stok} ${p.satuan}'.trim()),
            trailing: Text(rp(p.hargaUmum),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            onTap: habis ? null : () => _tambah(p),
          ),
        );
      },
    );
  }
}