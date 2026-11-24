import 'package:flutter/material.dart';
import '../main.dart';
import '../services/api_service.dart';

class StokPage extends StatefulWidget {
  const StokPage({super.key});

  @override
  State<StokPage> createState() => _StokPageState();
}

class _StokPageState extends State<StokPage> {
  // Batas stok dianggap menipis
  static const int _batasMenipis = 10;

  List<dynamic> _produk = [];
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await ApiService.getProduk();
    if (!mounted) return;
    setState(() {
      _produk = list;
      _loading = false;
    });
  }

  int _stokOf(dynamic p) {
    final v = p['stok'];
    return v is num ? v.toInt() : int.tryParse('$v') ?? 0;
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
      ),
      body: Column(children: [
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
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : data.isEmpty
              ? const Center(child: Text('Produk tidak ditemukan'))
              : RefreshIndicator(
            onRefresh: _load,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              itemCount: data.length,
              itemBuilder: (_, i) {
                final p = data[i];
                final stok = _stokOf(p);
                final menipis = stok <= _batasMenipis;
                final satuan = '${p['satuan_dasar'] ?? ''}';
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                      menipis ? Colors.red : kPrimary,
                      child: Icon(
                          menipis
                              ? Icons.warning_amber
                              : Icons.inventory_2,
                          color: Colors.white),
                    ),
                    title: Text('${p['nama']}'),
                    subtitle: Text(menipis
                        ? (stok == 0 ? 'Stok habis' : 'Stok menipis')
                        : 'Stok tersedia'),
                    trailing: Text(
                      '$stok $satuan'.trim(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: menipis ? Colors.red : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ]),
    );
  }
}