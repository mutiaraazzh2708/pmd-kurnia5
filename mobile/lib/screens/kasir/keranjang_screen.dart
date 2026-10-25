import 'package:flutter/material.dart';

class ItemKeranjang {
  final String nama;
  final int hargaUmum;
  final int hargaGrosir;
  int jumlah;

  ItemKeranjang({
    required this.nama,
    required this.hargaUmum,
    required this.hargaGrosir,
    this.jumlah = 1,
  });
}

class KeranjangScreen extends StatefulWidget {
  const KeranjangScreen({super.key});

  @override
  State<KeranjangScreen> createState() => _KeranjangScreenState();
}

class _KeranjangScreenState extends State<KeranjangScreen> {
  // Data tiruan. Nanti diganti data dari layar kasir dan API.
  final List<ItemKeranjang> _items = [
    ItemKeranjang(nama: 'Gula Pasir 1 kg', hargaUmum: 15000, hargaGrosir: 14000, jumlah: 2),
    ItemKeranjang(nama: 'Minyak Goreng 1 L', hargaUmum: 18000, hargaGrosir: 17000),
    ItemKeranjang(nama: 'Beras 5 kg', hargaUmum: 70000, hargaGrosir: 67000),
  ];

  String _tipePembeli = 'umum';
  String _metodeBayar = 'tunai';

  int _harga(ItemKeranjang i) =>
      _tipePembeli == 'umum' ? i.hargaUmum : i.hargaGrosir;

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

  void _ubahJumlah(ItemKeranjang item, int delta) {
    setState(() {
      item.jumlah += delta;
      if (item.jumlah <= 0) _items.remove(item);
    });
  }

  // Nanti diisi POST transaksi ke API.
  void _bayar() {
    debugPrint('Transaksi: tipe=$_tipePembeli, metode=$_metodeBayar, total=$_total, '
        'item=${_items.map((i) => '${i.nama} x${i.jumlah}').toList()}');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi tercetak di konsol')),
    );
  }

  void _konfirmasi() {
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
                      subtitle: Text(_rp(_harga(item))),
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
                    ButtonSegment(value: 'umum', label: Text('Umum')),
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
                    ButtonSegment(value: 'transfer', label: Text('Transfer')),
                  ],
                  selected: {_metodeBayar},
                  onSelectionChanged: (s) =>
                      setState(() => _metodeBayar = s.first),
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
                    onPressed: _items.isEmpty ? null : _konfirmasi,
                    child: const Text('Bayar'),
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