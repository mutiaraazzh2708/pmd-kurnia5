import 'package:intl/intl.dart';

String rupiah(num angka) {
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(angka);
}

String tanggal(DateTime d) => DateFormat('dd/MM/yyyy HH:mm').format(d);