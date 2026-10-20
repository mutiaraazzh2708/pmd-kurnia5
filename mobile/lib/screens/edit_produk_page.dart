import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Halaman form edit produk (US-04).
/// Saat ini hanya tampilan: tombol Simpan belum memanggil API.
/// Integrasi API dikerjakan di issue terpisah (US-02).
class EditProdukPage extends StatefulWidget {
  const EditProdukPage({
    super.key,
    this.nama = 'Beras 5 kg',
    this.harga = 65000,
    this.stok = 12,
    this.deskripsi = '',
  });

  // Nilai awal form. Nanti diisi dari data produk yang dipilih.
  final String nama;
  final int harga;
  final int stok;
  final String deskripsi;

  @override
  State<EditProdukPage> createState() => _EditProdukPageState();
}

class _EditProdukPageState extends State<EditProdukPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _namaController;
  late final TextEditingController _hargaController;
  late final TextEditingController _stokController;
  late final TextEditingController _deskripsiController;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.nama);
    _hargaController = TextEditingController(text: widget.harga.toString());
    _stokController = TextEditingController(text: widget.stok.toString());
    _deskripsiController = TextEditingController(text: widget.deskripsi);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _stokController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  String? _wajibDiisi(String? value, String namaField) {
    if (value == null || value.trim().isEmpty) {
      return '$namaField wajib diisi';
    }
    return null;
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    // TODO(US-02): panggil API untuk menyimpan perubahan produk.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perubahan disimpan (belum terhubung API)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Produk')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _namaController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nama Produk',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => _wajibDiisi(v, 'Nama produk'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hargaController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Harga',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => _wajibDiisi(v, 'Harga'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _stokController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Stok',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => _wajibDiisi(v, 'Stok'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _deskripsiController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi (opsional)',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _simpan,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Simpan Perubahan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}