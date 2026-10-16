import 'package:flutter/material.dart';
import '../model/lapangan.dart';
import '../pembantu/alat.dart';
import '../pembantu/tema.dart';

class LapanganItem extends StatelessWidget {
  final Lapangan lapangan;
  final VoidCallback onTap;
  const LapanganItem({super.key, required this.lapangan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(
          backgroundColor: warnaUtama,
          child: Icon(Icons.sports_tennis, color: warnaAksen),
        ),
        title: Text(lapangan.namaLapangan,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${rupiah(lapangan.hargaPerJam)}/jam'),
        trailing: Chip(
          label: Text(lapangan.jenis, style: const TextStyle(fontSize: 12)),
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}
