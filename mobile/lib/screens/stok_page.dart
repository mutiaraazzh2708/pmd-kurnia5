import 'package:flutter/material.dart';
import '../main.dart';
import '../services/api_service.dart';
import '../utils/validators.dart';
import '../widgets/form_helpers.dart';
import 'barang_masuk_page.dart';
import 'mutasi_page.dart';

class StokPage extends StatefulWidget {
  const StokPage({super.key});

  @override
  State<StokPage> createState() => _StokPageState();
}

class _StokPageState extends State<StokPage> {
  // Batas stok dianggap menipis (sepakati dengan tim)
  static const int _batasMenipis = 10;

  List<dynamic> _produk = [];
  bool _loading = true;
  String? _error;
  String _query = '';
  String _lokasi = 'Gudang'; // 'Gudang' atau 'Toko'

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await ApiService.getProduk();
      if (!mounted) return;
      setState(() {
        _produk = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = pesanError(e);
        _loading = false;
      });
    }
  }

  int? _stokOf(dynamic p) =>
      _lokasi == 'Gudang' ? StokUtil.gudang(p) : StokUtil.toko(p);

  /// Buka halaman lain, lalu muat ulang stok saat kembali.
  Future<void> _buka(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.toLowerCase();
    final data = _produk
        .where((p) => '${p['nama']}'.toLowerCase().contains(q))
        .toList();

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Stok Barang'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Mutasi',
            icon: const Icon(Icons.swap_horiz),
            onPressed: () => _buka(const MutasiPage()),
          ),
          IconButton(
            tooltip: 'Barang Masuk',
            icon: const Icon(Icons.move_to_inbox),
            onPressed: () => _buka(const BarangMasukPage()),
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Gudang', label: Text('Gudang')),
                ButtonSegment(value: 'Toko', label: Text('Toko')),
              ],
              selected: {_lokasi},
              onSelectionChanged: (s) => setState(() => _lokasi = s.first),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              hintText: 'Cari produk...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(child: _buildList(data)),
      ]),
    );
  }

  Widget _buildList(List<dynamic> data) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: _load, child: const Text('Coba lagi')),
        ]),
      );
    }
    if (data.isEmpty) {
      return const Center(child: Text('Produk tidak ditemukan'));
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        itemCount: data.length,
        itemBuilder: (_, i) {
          final p = data[i];
          final stok = _stokOf(p);
          final menipis = stok != null && stok <= _batasMenipis;
          final satuan = '${p['satuan_dasar'] ?? ''}';
          final warna = menipis ? Colors.red : kPrimary;

          return Card(
            child: ListTile(
              leading: Container(
                width: 52,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: warna,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('STOK',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
              title: Text('${p['nama']}'),
              subtitle: Text(stok == null
                  ? 'Data stok ${_lokasi.toLowerCase()} belum tersedia'
                  : stok == 0
                  ? 'Stok habis'
                  : menipis
                  ? 'Stok menipis'
                  : 'Stok tersedia'),
              trailing: Text(
                stok == null ? '-' : '$stok $satuan'.trim(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: menipis ? Colors.red : Colors.black87,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}