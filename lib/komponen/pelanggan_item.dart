import 'package:flutter/material.dart';
import '../model/pelanggan.dart';
import '../pembantu/tema.dart';

class PelangganItem extends StatelessWidget {
  final Pelanggan pelanggan;
  final VoidCallback onTap;
  const PelangganItem({super.key, required this.pelanggan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final huruf =
        pelanggan.nama.isEmpty ? '?' : pelanggan.nama[0].toUpperCase();
    return Card(
      color: Colors.white,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: warnaUtama,
          child: Text(huruf, style: const TextStyle(color: warnaAksen)),
        ),
        title: Text(pelanggan.nama,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(pelanggan.noHp),
      ),
    );
  }
}
