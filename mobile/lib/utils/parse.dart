// Backend mengirim angka sebagai string, misalnya "15000.00".
int toInt(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  return (num.tryParse(v.toString()) ?? 0).toInt();
}