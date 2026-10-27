import 'package:flutter/material.dart';
import '../../services/kasir_service.dart';
import '../struk_screen.dart';

class ItemKeranjang {
  final int productId;
  final String nama;
  final int hargaEceran;
  final int hargaGrosir;
  final int stok;
  int jumlah;

  ItemKeranjang({
    required this.productId,
    required this.nama,
    required this.hargaEceran,
    required this.hargaGrosir,
    required this.stok,
    this.jumlah = 1,
  });
}

class KeranjangScreen extends StatefulWidget {
  // Daftar item dikirim dari layar Kasir.
  final List<ItemKeranjang> items;

  const KeranjangScreen({super.key, required this.items});

  @override
  State<KeranjangScreen> createState() => _KeranjangScreenState();
}

class _KeranjangScreenState extends State<KeranjangScreen> {
  // Sama dengan list di layar Kasir, jadi perubahan di sini ikut terbawa.
  late final List<ItemKeranjang> _items = widget.items;

  String _tipePembeli = 'eceran';
  String _metodeBayar = 'tunai';

  bool _menyimpan = false;
  String? _errorValidasi;

  int _harga(ItemKeranjang i) =>
      _tipePembeli == 'eceran' ? i.hargaEceran : i.hargaGrosir;

  int get _total => _items.fold(0, (sum, i) => sum + _harga(i) * i.jumlah);

  String _rp(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp $buf';
  }

  void _snack(String pesan, {bool error = true}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  void _ubahJumlah(ItemKeranjang item, int delta) {
    // Tidak boleh melebihi stok.
    if (delta > 0 && item.jumlah + delta > item.stok) {
      _snack('Stok ${item.nama} hanya ${item.stok}');
      return;
    }
    setState(() {
      item.jumlah += delta;
      if (item.jumlah <= 0) _items.remove(item);
      _errorValidasi = null;
    });
  }

  // Validasi transaksi (#55). Mengembalikan pesan error, null jika valid.
  String? _validasi() {
    if (_items.isEmpty) return 'Keranjang masih kosong';
    for (final i in _items) {
      if (i.jumlah < 1) return 'Jumlah ${i.nama} minimal 1';
      if (i.jumlah > i.stok) {
        return 'Stok ${i.nama} tidak cukup (sisa ${i.stok})';
      }
    }
    return null;
  }

  // Kirim transaksi ke API (#43), lalu buka layar struk.
  Future<void> _bayar() async {
    setState(() => _menyimpan = true);
    try {
      final trx = await KasirService.simpanTransaksi(
        items: _items
            .map((i) => {'product_id': i.productId, 'qty': i.jumlah})
            .toList(),
        tipe: _tipePembeli,
        metode: _metodeBayar,
      );
      _items.clear(); // kosongkan keranjang setelah berhasil
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => StrukScreen(transaksi: trx)),
      );
    } catch (e) {
      // Pesan dari server, misalnya stok tidak cukup.
      if (mounted) _snack(e.toString());
    } finally {
      if (mounted) setState(() => _menyimpan = false);
    }
  }

  void _konfirmasi() {
    final err = _validasi();
    setState(() => _errorValidasi = err);
    if (err != null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi pembayaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipe pembeli: $_tipePembeli'),
            Text('Metode bayar: $_metodeBayar'),
            const SizedBox(height: 8),
            Text('Total: ${_rp(_total)}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _bayar();
            },
            child: const Text('Bayar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang')),
      body: Column(
        children: [
          Expanded(
            child: _items.isEmpty
                ? const Center(child: Text('Keranjang kosong'))
                : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final item in _items)
                  Card(
                    child: ListTile(
                      title: Text(item.nama),
                      subtitle: Text(
                          '${_rp(_harga(item))}  |  Stok ${item.stok}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => _ubahJumlah(item, -1),
                          ),
                          Text('${item.jumlah}'),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => _ubahJumlah(item, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                const Text('Tipe pembeli'),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'eceran', label: Text('Eceran')),
                    ButtonSegment(value: 'grosir', label: Text('Grosir')),
                  ],
                  selected: {_tipePembeli},
                  onSelectionChanged: (s) =>
                      setState(() => _tipePembeli = s.first),
                ),
                const SizedBox(height: 16),
                const Text('Metode bayar'),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'tunai', label: Text('Tunai')),
                    ButtonSegment(
                        value: 'transfer', label: Text('Transfer')),
                  ],
                  selected: {_metodeBayar},
                  onSelectionChanged: (s) =>
                      setState(() => _metodeBayar = s.first),
                ),
                if (_errorValidasi != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _errorValidasi!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Total\n${_rp(_total)}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton(
                    onPressed:
                    (_items.isEmpty || _menyimpan) ? null : _konfirmasi,
                    child: _menyimpan
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text('Bayar'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}