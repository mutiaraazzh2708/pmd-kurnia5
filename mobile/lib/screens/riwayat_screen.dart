import 'package:flutter/material.dart';
import '../models/transaksi.dart';
import '../services/kasir_service.dart';
import '../utils/format.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});
  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  String _periode = 'hari_ini';
  late Future<List<Transaksi>> _future;

  @override
  void initState() {
    super.initState();
    _future = KasirService.riwayat(_periode);
  }

  void _muatUlang() {
    setState(() => _future = KasirService.riwayat(_periode));
  }

  Future<void> _lihatDetail(Transaksi t) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => FutureBuilder<Transaksi>(
        future: KasirService.detail(t.id),
        builder: (c, s) {
          if (s.connectionState != ConnectionState.done) {
            return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
          }
          if (s.hasError) {
            return SizedBox(height: 200, child: Center(child: Text('${s.error}')));
          }
          final d = s.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(d.nomor, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(tanggal(d.tanggal)),
              const Divider(),
              ...d.items.map((e) => Text('${e.nama} x${e.qty}  -  ${rupiah(e.harga * e.qty)}')),
              const Divider(),
              Text('Total: ${rupiah(d.total)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ]),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Transaksi')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'hari_ini', label: Text('Hari ini')),
              ButtonSegment(value: 'minggu_ini', label: Text('Minggu ini')),
              ButtonSegment(value: 'semua', label: Text('Semua')),
            ],
            selected: {_periode},
            onSelectionChanged: (s) {
              _periode = s.first;
              _muatUlang();
            },
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Transaksi>>(
            future: _future,
            builder: (c, s) {
              if (s.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (s.hasError) return Center(child: Text('${s.error}'));
              final data = s.data!;
              if (data.isEmpty) return const Center(child: Text('Belum ada transaksi'));
              return RefreshIndicator(
                onRefresh: () async => _muatUlang(),
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (_, i) {
                    final t = data[i];
                    return Card(
                      child: ListTile(
                        title: Text(t.nomor),
                        subtitle: Text('${tanggal(t.tanggal)}  |  ${t.metodeBayar}'),
                        trailing: Text(rupiah(t.total),
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        onTap: () => _lihatDetail(t),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}