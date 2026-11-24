import 'package:flutter/material.dart';
import '../utils/validators.dart';

String fmtTanggal(String iso) {
  if (iso.length >= 10 && iso[4] == '-') {
    return '${iso.substring(8, 10)}/${iso.substring(5, 7)}/${iso.substring(0, 4)}';
  }
  return iso;
}

String tanggalIso(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String pesanError(Object e) => '$e'.replaceFirst('Exception: ', '');

/// Dialog konfirmasi, mis. "Simpan mutasi?". Mengembalikan true jika "Ya".
Future<bool> konfirmasi(
    BuildContext context, {
      required String judul,
      required String isi,
    }) async {
  final hasil = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(judul),
      content: Text(isi),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal')),
        FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, simpan')),
      ],
    ),
  );
  return hasil ?? false;
}

/// Kolom tanggal yang menolak tanggal di masa depan.
class TanggalField extends FormField<DateTime> {
  TanggalField({
    super.key,
    required DateTime value,
    required ValueChanged<DateTime> onChanged,
  }) : super(
    initialValue: value,
    validator: Validators.tanggal,
    builder: (state) {
      return InkWell(
        onTap: () async {
          final now = DateTime.now();
          final d = await showDatePicker(
            context: state.context,
            initialDate: state.value ?? now,
            firstDate: DateTime(2020),
            lastDate: DateTime(now.year, now.month, now.day),
          );
          if (d != null) {
            state.didChange(d);
            onChanged(d);
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Tanggal',
            suffixIcon: const Icon(Icons.calendar_today),
            errorText: state.errorText,
          ),
          child: Text(state.value == null
              ? ''
              : fmtTanggal(tanggalIso(state.value!))),
        ),
      );
    },
  );
}