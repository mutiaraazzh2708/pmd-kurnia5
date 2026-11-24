import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/mutasi_provider.dart';
import '../services/api_service.dart';
import '../utils/validators.dart';
import '../widgets/form_helpers.dart';

class MutasiPage extends StatefulWidget {
  const MutasiPage({super.key});

  @override
  State<MutasiPage> createState() => _MutasiPageState();
}

class _MutasiPageState extends State<MutasiPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => context.read<MutasiProvider>().fetch());
  }

  Future<void> _openForm() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const MutasiFormPage()),
    );
    if (saved == true && mounted) {
      context.read<MutasiProvider>().fetch(); // refresh daftar
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
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: const [
          Icon(Icons.swap_horiz, size: 56, color: Colors.grey),
          SizedBox(height: 8),
          Text('Belum ada mutasi'),
        ]),
      );
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
                '${m.asal} → ${m.tujuan} • ${fmtTanggal(m.tanggal)}'
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
  final _formKey = GlobalKey<FormState>();
  final _jumlah = TextEditingController();
  final _ket = TextEditingController();

  List<dynamic> _produk = [];
  bool _loadingProduk = true;
  bool _saving = false;

  int? _produkId;
  String _asal = 'Gudang'; // 'Gudang' = Gudang → Toko, 'Toko' = Toko → Gudang
  DateTime _tanggal = DateTime.now();

  String get _tujuan => _asal == 'Gudang' ? 'Toko' : 'Gudang';

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

  dynamic get _produkTerpilih {
    if (_produkId == null) return null;
    return _produk.firstWhere((e) => '${e['id']}' == '$_produkId',
        orElse: () => null);
  }

  /// Stok di lokasi asal. null = API tidak mengirim stok lokasi itu.
  int? get _stokAsal {
    final p = _produkTerpilih;
    if (p == null) return null;
    return _asal == 'Gudang' ? StokUtil.gudang(p) : StokUtil.toko(p);
  }

  Future<void> _simpan() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return; // validasi dulu (#69)

    final p = _produkTerpilih;
    final ya = await konfirmasi(
      context,
      judul: 'Simpan mutasi?',
      isi: '${p?['nama'] ?? 'Produk'}\n'
          '$_asal → $_tujuan\n'
          'Jumlah: ${_jumlah.text.trim()}',
    );
    if (!ya || !mounted) return;

    setState(() => _saving = true);
    try {
      await context.read<MutasiProvider>().tambah(
        produkId: _produkId!,
        jumlah: int.parse(_jumlah.text.trim()),
        asal: _asal,
        tujuan: _tujuan,
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
    final stok = _stokAsal;

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
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                    value: 'Gudang', label: Text('Gudang → Toko')),
                ButtonSegment(
                    value: 'Toko', label: Text('Toko → Gudang')),
              ],
              selected: {_asal},
              onSelectionChanged: (s) => setState(() => _asal = s.first),
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
              onChanged: (v) => setState(() => _produkId = v),
              validator: Validators.produk,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _jumlah,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                labelText: 'Jumlah',
                helperText:
                stok == null ? null : 'Stok $_asal: $stok',
              ),
              validator: (v) => Validators.jumlah(v,
                  maxStok: stok, lokasi: _asal.toLowerCase()),
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