import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/kasir_service.dart';
import '../../utils/format.dart';
import 'keranjang_screen.dart';

class KasirScreen extends StatefulWidget {
  const KasirScreen({super.key});

  @override
  State<KasirScreen> createState() => _KasirScreenState();
}

class _KasirScreenState extends State<KasirScreen> {
  final _cariCtrl = TextEditingController();
  Timer? _debounce;

  // Isi keranjang disimpan di sini, lalu dikirim ke KeranjangScreen.
  final List<ItemKeranjang> _keranjang = [];

  List<Product> _hasil = [];
  bool _loading = false;
  String? _error;

  int get _jumlahItem => _keranjang.fold(0, (s, i) => s + i.jumlah);
  int get _total =>
      _keranjang.fold(0, (s, i) => s + i.hargaEceran * i.jumlah);

  @override
  void initState() {
    super.initState();
    _cari(''); // tampilkan daftar awal
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _cariCtrl.dispose();
    super.dispose();
  }

  // Autocomplete (#47): tunggu 400 ms setelah berhenti mengetik.
  void _onChanged(String teks) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final q = teks.trim();
      if (q.length == 1) return; // minimal 2 huruf, kosong = tampilkan semua
      _cari(q);
    });
  }

  Future<void> _cari(String q) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await KasirService.cariProduk(q);
      if (!mounted) return;
      setState(() => _hasil = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String pesan, {bool error = true}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(pesan),
      backgroundColor: error ? Colors.red : Colors.green,
      duration: const Duration(seconds: 1),
    ));
  }

  void _tambah(Product p) {
    final idx = _keranjang.indexWhere((e) => e.productId == p.id);
    if (idx >= 0) {
      if (_keranjang[idx].jumlah + 1 > p.stok) {
        _snack('Stok ${p.nama} hanya ${p.stok}');
        return;
      }
      setState(() => _keranjang[idx].jumlah++);
    } else {
      if (p.stok < 1) {
        _snack('Stok ${p.nama} habis');
        return;
      }
      setState(() => _keranjang.add(ItemKeranjang(
        productId: p.id,
        nama: p.nama,
        hargaEceran: p.hargaEceran,
        hargaGrosir: p.hargaGrosir,
        stok: p.stok,
      )));
    }
    _snack('${p.nama} ditambahkan', error: false);
  }

  Widget _kartuProduk(Product p) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 56,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('STOK',
                style: TextStyle(color: Colors.white, fontSize: 10)),
            Text('${p.stok}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ]),
        ),
        title: Text(p.nama),
        trailing: Text(rupiah(p.hargaEceran),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        onTap: () => _tambah(p),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _cariCtrl,
            onChanged: _onChanged,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Cari produk...',
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(_error!))
              : _hasil.isEmpty
              ? const Center(child: Text('Produk tidak ditemukan'))
              : ListView.builder(
            itemCount: _hasil.length,
            itemBuilder: (_, i) => _kartuProduk(_hasil[i]),
          ),
        ),
      ]),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton(
            onPressed: _keranjang.isEmpty
                ? null
                : () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => KeranjangScreen(items: _keranjang),
              ),
            ).then((_) => setState(() {})), // segarkan saat kembali
            style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48)),
            child: Text('Keranjang ($_jumlahItem) - ${rupiah(_total)}'),
          ),
        ),
      ),
    );
  }
}