import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/mutasi_provider.dart';
import '../services/api_service.dart';

String _fmtTanggal(String iso) {
  if (iso.length >= 10 && iso[4] == '-') {
    return '${iso.substring(8, 10)}/${iso.substring(5, 7)}/${iso.substring(0, 4)}';
  }
  return iso;
}

class MutasiPage extends StatefulWidget {
  const MutasiPage({super.key});

  @override
  State<MutasiPage> createState() => _MutasiPageState();
}

class _MutasiPageState extends State<MutasiPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
            (_) => context.read<MutasiProvider>().fetch());
  }

  Future<void> _openForm() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const MutasiFormPage()),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mutasi berhasil disimpan')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<MutasiProvider>();

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Mutasi Stok'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        onPressed: _openForm,
        icon: const Icon(Icons.add),
        label: const Text('Mutasi'),
      ),
      body: _buildBody(p),
    );
  }

  Widget _buildBody(MutasiProvider p) {
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
      return const Center(child: Text('Belum ada data mutasi'));
    }

    return RefreshIndicator(
      onRefresh: p.fetch,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
        itemCount: p.items.length,
        itemBuilder: (_, i) {
          final m = p.items[i];
          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: kPrimary,
                child: Icon(Icons.swap_horiz, color: Colors.white),
              ),
              title: Text(
                  m.produkNama.isEmpty ? 'Produk #${m.produkId}' : m.produkNama),
              subtitle: Text(
                '${m.asal} → ${m.tujuan} • ${_fmtTanggal(m.tanggal)}'
                    '${m.keterangan.isNotEmpty ? '\n${m.keterangan}' : ''}',
              ),
              isThreeLine: m.keterangan.isNotEmpty,
              trailing: Text('${m.jumlah}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          );
        },
      ),
    );
  }
}

// ======================= FORM =======================

class MutasiFormPage extends StatefulWidget {
  const MutasiFormPage({super.key});

  @override
  State<MutasiFormPage> createState() => _MutasiFormPageState();
}

class _MutasiFormPageState extends State<MutasiFormPage> {
  static const _lokasi = ['Gudang', 'Toko'];

  final _formKey = GlobalKey<FormState>();
  final _jumlah = TextEditingController();
  final _ket = TextEditingController();

  List<dynamic> _produk = [];
  bool _loadingProduk = true;
  bool _saving = false;

  int? _produkId;
  String? _asal = 'Gudang';
  String? _tujuan = 'Toko';
  DateTime _tanggal = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadProduk();
  }

  @override
  void dispose() {
    _jumlah.dispose();
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
      await context.read<MutasiProvider>().tambah(
        produkId: _produkId!,
        jumlah: int.parse(_jumlah.text.trim()),
        asal: _asal!,
        tujuan: _tujuan!,
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
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Tambah Mutasi'),
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
              value: _produkId,
              decoration: const InputDecoration(labelText: 'Produk'),
              items: _produk.map<DropdownMenuItem<int>>((e) {
                final id = e['id'] is int
                    ? e['id'] as int
                    : int.parse('${e['id']}');
                return DropdownMenuItem(
                    value: id, child: Text('${e['nama']}'));
              }).toList(),
              onChanged: (v) => setState(() => _produkId = v),
              validator: (v) => v == null ? 'Pilih produk' : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _asal,
              decoration: const InputDecoration(labelText: 'Dari'),
              items: _lokasi
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                  .toList(),
              onChanged: (v) => setState(() => _asal = v),
              validator: (v) => v == null ? 'Pilih lokasi asal' : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _tujuan,
              decoration: const InputDecoration(labelText: 'Ke'),
              items: _lokasi
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                  .toList(),
              onChanged: (v) => setState(() => _tujuan = v),
              validator: (v) {
                if (v == null) return 'Pilih lokasi tujuan';
                if (v == _asal) return 'Tujuan harus berbeda dari asal';
                return null;
              },
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