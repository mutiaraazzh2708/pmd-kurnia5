import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/barang_masuk_provider.dart';
import '../providers/supplier_provider.dart';
import '../services/api_service.dart';

String _fmtTanggal(String iso) {
  if (iso.length >= 10 && iso[4] == '-') {
    return '${iso.substring(8, 10)}/${iso.substring(5, 7)}/${iso.substring(0, 4)}';
  }
  return iso;
}

class BarangMasukPage extends StatefulWidget {
  const BarangMasukPage({super.key});

  @override
  State<BarangMasukPage> createState() => _BarangMasukPageState();
}

class _BarangMasukPageState extends State<BarangMasukPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BarangMasukProvider>().fetch();
      context.read<SupplierProvider>().fetch();
    });
  }

  Future<void> _openForm() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const BarangMasukFormPage()),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Barang masuk berhasil disimpan')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<BarangMasukProvider>();

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Barang Masuk'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        onPressed: _openForm,
        icon: const Icon(Icons.add),
        label: const Text('Barang Masuk'),
      ),
      body: _buildBody(p),
    );
  }

  Widget _buildBody(BarangMasukProvider p) {
    if (p.loading) return const Center(child: CircularProgressIndicator());
    if (p.error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(p.error!, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: p.fetch, child: const Text('Coba lagi')),
        ]),
      );
    }
    if (p.items.isEmpty) {
      return const Center(child: Text('Belum ada data barang masuk'));
    }

    return RefreshIndicator(
      onRefresh: p.fetch,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
        itemCount: p.items.length,
        itemBuilder: (_, i) {
          final b = p.items[i];
          final supplier =
          b.supplierNama.isEmpty ? 'Supplier #${b.supplierId}' : b.supplierNama;
          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: kPrimary,
                child: Icon(Icons.inventory_2, color: Colors.white),
              ),
              title: Text(
                  b.produkNama.isEmpty ? 'Produk #${b.produkId}' : b.produkNama),
              subtitle: Text(
                '$supplier • ${_fmtTanggal(b.tanggal)}'
                    '${b.keterangan.isNotEmpty ? '\n${b.keterangan}' : ''}',
              ),
              isThreeLine: b.keterangan.isNotEmpty,
              trailing: Text('+${b.jumlah}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green)),
            ),
          );
        },
      ),
    );
  }
}

// ======================= FORM =======================

class BarangMasukFormPage extends StatefulWidget {
  const BarangMasukFormPage({super.key});

  @override
  State<BarangMasukFormPage> createState() => _BarangMasukFormPageState();
}

class _BarangMasukFormPageState extends State<BarangMasukFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _jumlah = TextEditingController();
  final _harga = TextEditingController();
  final _ket = TextEditingController();

  List<dynamic> _produk = [];
  bool _loadingProduk = true;
  bool _saving = false;

  int? _supplierId;
  int? _produkId;
  DateTime _tanggal = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadProduk();
  }

  @override
  void dispose() {
    _jumlah.dispose();
    _harga.dispose();
    _ket.dispose();
    super.dispose();
  }

  Future<void> _loadProduk() async {
    final list = await ApiService.getProduk();
    if (!mounted) return;
    setState(() {
      _produk = list;
      _loadingProduk = false;
    });
  }

  String get _tanggalIso =>
      '${_tanggal.year}-${_tanggal.month.toString().padLeft(2, '0')}-${_tanggal.day.toString().padLeft(2, '0')}';

  Future<void> _pickTanggal() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (d != null) setState(() => _tanggal = d);
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await context.read<BarangMasukProvider>().tambah(
        supplierId: _supplierId!,
        produkId: _produkId!,
        jumlah: int.parse(_jumlah.text.trim()),
        hargaBeli: double.parse(_harga.text.trim()),
        tanggal: _tanggalIso,
        keterangan: _ket.text.trim(),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final suppliers = context.watch<SupplierProvider>().items;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Tambah Barang Masuk'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
      ),
      body: _loadingProduk
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<int>(
              value: _supplierId,
              decoration: const InputDecoration(labelText: 'Supplier'),
              items: suppliers
                  .where((s) => s.id != null)
                  .map((s) =>
                  DropdownMenuItem(value: s.id, child: Text(s.nama)))
                  .toList(),
              onChanged: (v) => setState(() => _supplierId = v),
              validator: (v) => v == null ? 'Pilih supplier' : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<int>(
              value: _produkId,
              decoration: const InputDecoration(labelText: 'Produk'),
              items: _produk.map<DropdownMenuItem<int>>((e) {
                final id = e['id'] is int
                    ? e['id'] as int
                    : int.parse('${e['id']}');
                return DropdownMenuItem(
                    value: id, child: Text('${e['nama']}'));
              }).toList(),
              onChanged: (v) {
                setState(() => _produkId = v);
                final item = _produk.firstWhere(
                        (e) => '${e['id']}' == '$v',
                    orElse: () => null);
                if (item != null && _harga.text.isEmpty) {
                  _harga.text = '${item['harga_beli'] ?? ''}'
                      .replaceAll(RegExp(r'\.0+$'), '');
                }
              },
              validator: (v) => v == null ? 'Pilih produk' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _jumlah,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Jumlah'),
              validator: (v) {
                final n = int.tryParse((v ?? '').trim());
                if (n == null || n <= 0) {
                  return 'Jumlah harus lebih dari 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _harga,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Harga Beli (per satuan)',
                  prefixText: 'Rp '),
              validator: (v) {
                final n = double.tryParse((v ?? '').trim());
                if (n == null || n < 0) return 'Harga tidak valid';
                return null;
              },
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: _pickTanggal,
              child: InputDecorator(
                decoration: const InputDecoration(
                    labelText: 'Tanggal',
                    suffixIcon: Icon(Icons.calendar_today)),
                child: Text(_fmtTanggal(_tanggalIso)),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _ket,
              maxLines: 2,
              decoration: const InputDecoration(
                  labelText: 'Keterangan (opsional)'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: kPrimary),
                onPressed: _saving ? null : _simpan,
                child: _saving
                    ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                    : const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}