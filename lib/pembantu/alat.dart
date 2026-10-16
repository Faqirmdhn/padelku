import 'package:flutter/material.dart';

/// Ubah nilai dari API (int/double/String) menjadi int.
int keInt(dynamic nilai) {
  if (nilai is num) return nilai.toInt();
  return int.tryParse('$nilai') ?? 0;
}

/// 150000 -> "Rp 150.000"
String rupiah(int angka) {
  final s = angka.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp $buf';
}

/// DateTime -> "2026-10-20"
String formatTanggal(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// TimeOfDay -> "19:00"
String formatJam(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

Color warnaStatus(String status) {
  switch (status) {
    case 'selesai':
      return Colors.green;
    case 'dibatalkan':
      return Colors.red;
    default:
      return Colors.blue;
  }
}

Widget chipStatus(String status) => Chip(
      label: Text(status,
          style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: warnaStatus(status),
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );

/// Dialog konfirmasi hapus. true = lanjut hapus.
Future<bool> konfirmasiHapus(BuildContext context) async {
  final hasil = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Hapus Data'),
      content: const Text('Yakin ingin menghapus data ini?'),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
  return hasil ?? false;
}

void tampilPesan(BuildContext context, String pesan) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
}

/// Tombol selebar layar.
class TombolLebar extends StatelessWidget {
  final String teks;
  final VoidCallback? onPressed;
  const TombolLebar({super.key, required this.teks, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(onPressed: onPressed, child: Text(teks)),
    );
  }
}

/// Tampilan saat gagal memuat data dari API.
Widget tampilanGagal(VoidCallback ulang) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            'Gagal memuat data.\nPeriksa koneksi dan URL API di klien_api.dart.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: ulang, child: const Text('Coba Lagi')),
        ],
      ),
    ),
  );
}

/// Satu baris label + nilai di halaman detail.
Widget barisDetail(String label, String nilai) {
  return ListTile(
    title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    subtitle: Text(nilai,
        style: const TextStyle(fontSize: 16, color: Colors.black87)),
  );
}
