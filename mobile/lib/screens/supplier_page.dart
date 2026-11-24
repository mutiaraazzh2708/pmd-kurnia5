import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/supplier.dart';
import '../providers/supplier_provider.dart';

class SupplierPage extends StatefulWidget {
  const SupplierPage({super.key});

  @override
  State<SupplierPage> createState() => _SupplierPageState();
}

class _SupplierPageState extends State<SupplierPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
            (_) => context.read<SupplierProvider>().fetch());
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _showForm({Supplier? supplier}) async {
    final nama = TextEditingController(text: supplier?.nama);
    final alamat = TextEditingController(text: supplier?.alamat);
    final telp = TextEditingController(text: supplier?.telepon);
    final formKey = GlobalKey<FormState>();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(supplier == null ? 'Tambah Supplier' : 'Edit Supplier'),
        content: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: nama,
              decoration: const InputDecoration(labelText: 'Nama'),
              validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: alamat,
              decoration: const InputDecoration(labelText: 'Alamat'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: telp,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Telepon'),
            ),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: kPrimary),
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;
    try {
      await context.read<SupplierProvider>().save(Supplier(
        id: supplier?.id,
        nama: nama.text.trim(),
        alamat: alamat.text.trim(),
        telepon: telp.text.trim(),
      ));
      _toast('Supplier berhasil disimpan');
    } catch (e) {
      _toast('$e');
    }
  }

  Future<void> _confirmDelete(Supplier s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Supplier'),
        content: Text('Hapus "${s.nama}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await context.read<SupplierProvider>().remove(s.id!);
      _toast('Supplier dihapus');
    } catch (e) {
      _toast('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SupplierProvider>();

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Supplier'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            onChanged: p.setQuery,
            decoration: const InputDecoration(
              hintText: 'Cari supplier...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(child: _buildList(p)),
      ]),
    );
  }

  Widget _buildList(SupplierProvider p) {
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
      return const Center(child: Text('Belum ada supplier'));
    }

    return RefreshIndicator(
      onRefresh: p.fetch,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
        itemCount: p.items.length,
        itemBuilder: (_, i) {
          final s = p.items[i];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: kPrimary,
                child: Text(
                  s.nama.isNotEmpty ? s.nama[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(s.nama),
              subtitle: Text(
                  [s.telepon, s.alamat].where((e) => e.isNotEmpty).join(' • ')),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showForm(supplier: s)),
                IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(s)),
              ]),
            ),
          );
        },
      ),
    );
  }
}