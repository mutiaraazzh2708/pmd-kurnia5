import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/barang_masuk_provider.dart';
import '../providers/supplier_provider.dart';
import '../services/api_service.dart';
import '../utils/validators.dart';
import '../widgets/form_helpers.dart';

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
      context.read<BarangMasukProvider>().fetch();
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
          final supplier = b.supplierNama.isEmpty
              ? 'Supplier #${b.supplierId}'
              : b.supplierNama;
          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: kPrimary,
                child: Icon(Icons.inventory_2, color: Colors.white),
              ),
              title: Text(
                  b.produkNama.isEmpty ? 'Produk #${b.produkId}' : b.produkNama),
              subtitle: Text(
                '$supplier • ${fmtTanggal(b.tanggal)}'
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
    try {
      final list = await ApiService.getProduk();
      if (!mounted) return;
      setState(() {
        _produk = list;
        _loadingProduk = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingProduk = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(pesanError(e))));
    }
  }

  Future<void> _simpan() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return; // validasi dulu (#69)

    final namaProduk = _produk
        .firstWhere((e) => '${e['id']}' == '$_produkId', orElse: () => null)
    ?['nama'];
    final ya = await konfirmasi(
      context,
      judul: 'Simpan barang masuk?',
      isi: '${namaProduk ?? 'Produk'}\nJumlah: ${_jumlah.text.trim()}',
    );
    if (!ya || !mounted) return;

    setState(() => _saving = true);
    try {
      await context.read<BarangMasukProvider>().tambah(
        supplierId: _supplierId!,
        produkId: _produkId!,
        jumlah: int.parse(_jumlah.text.trim()),
        hargaBeli: double.parse(_harga.text.trim()),
        tanggal: tanggalIso(_tanggal),
        keterangan: _ket.text.trim(),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(pesanError(e))));
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
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Supplier'),
              items: suppliers
                  .where((s) => s.id != null)
                  .map((s) => DropdownMenuItem(
                  value: s.id, child: Text(s.nama)))
                  .toList(),
              onChanged: (v) => setState(() => _supplierId = v),
              validator: (v) => v == null ? 'Pilih supplier' : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<int>(
              value: _produkId,
              isExpanded: true,
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
              validator: Validators.produk,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _jumlah,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(labelText: 'Jumlah'),
              validator: (v) => Validators.jumlah(v),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _harga,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
              ],
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                  labelText: 'Harga Beli (per satuan)',
                  prefixText: 'Rp '),
              validator: Validators.hargaBeli,
            ),
            const SizedBox(height: 14),
            TanggalField(
              value: _tanggal,
              onChanged: (d) => _tanggal = d,
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
                style:
                FilledButton.styleFrom(backgroundColor: kPrimary),
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