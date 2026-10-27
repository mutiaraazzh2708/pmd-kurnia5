import 'package:flutter/material.dart';

class FormReturScreen extends StatefulWidget {
  const FormReturScreen({super.key});

  @override
  State<FormReturScreen> createState() => _FormReturScreenState();
}

class _FormReturScreenState extends State<FormReturScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noTransaksiCtrl = TextEditingController();
  final _produkCtrl = TextEditingController();
  final _jumlahCtrl = TextEditingController();
  final _keteranganCtrl = TextEditingController();
  String _alasan = 'rusak';

  static const _daftarAlasan = ['rusak', 'kedaluwarsa', 'salah_barang', 'lainnya'];

  @override
  void dispose() {
    _noTransaksiCtrl.dispose();
    _produkCtrl.dispose();
    _jumlahCtrl.dispose();
    _keteranganCtrl.dispose();
    super.dispose();
  }

  void _simpan() {
    final data = {
      'no_transaksi': _noTransaksiCtrl.text,
      'produk': _produkCtrl.text,
      'jumlah': _jumlahCtrl.text,
      'alasan': _alasan,
      'keterangan': _keteranganCtrl.text,
    };
    debugPrint('Data retur: $data');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data tercetak di konsol')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Retur Barang')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _noTransaksiCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nomor transaksi',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _produkCtrl,
                decoration: const InputDecoration(
                  labelText: 'Produk',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jumlahCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah retur',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _alasan,
                decoration: const InputDecoration(
                  labelText: 'Alasan retur',
                  border: OutlineInputBorder(),
                ),
                items: _daftarAlasan
                    .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                    .toList(),
                onChanged: (v) => setState(() => _alasan = v ?? _alasan),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _keteranganCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Keterangan (opsional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _simpan,
                  child: const Text('Simpan Retur'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}