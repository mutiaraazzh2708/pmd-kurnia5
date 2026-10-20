import 'package:flutter/material.dart';

class FormTambahProdukScreen extends StatefulWidget {
  const FormTambahProdukScreen({super.key});

  @override
  State<FormTambahProdukScreen> createState() => _FormTambahProdukScreenState();
}

class _FormTambahProdukScreenState extends State<FormTambahProdukScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _satuanCtrl = TextEditingController();
  final _hargaBeliCtrl = TextEditingController();
  final _hargaJualCtrl = TextEditingController();
  final _stokAwalCtrl = TextEditingController();

  @override
  void dispose() {
    _namaCtrl.dispose();
    _satuanCtrl.dispose();
    _hargaBeliCtrl.dispose();
    _hargaJualCtrl.dispose();
    _stokAwalCtrl.dispose();
    super.dispose();
  }

  void _simpan() {
    final data = {
      'nama': _namaCtrl.text,
      'satuan_dasar': _satuanCtrl.text,
      'harga_beli': _hargaBeliCtrl.text,
      'harga_jual': _hargaJualCtrl.text,
      'stok_awal': _stokAwalCtrl.text,
    };
    debugPrint('Data produk: $data');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data tercetak di konsol')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Produk')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama produk',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _satuanCtrl,
                decoration: const InputDecoration(
                  labelText: 'Satuan dasar (kg, pcs, liter)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hargaBeliCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga beli',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hargaJualCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga jual',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stokAwalCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stok awal',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _simpan,
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}