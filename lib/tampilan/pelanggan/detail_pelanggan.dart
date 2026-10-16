import 'package:flutter/material.dart';
import '../../layanan/layanan_pelanggan.dart';
import '../../model/pelanggan.dart';
import '../../pembantu/alat.dart';
import 'form_pelanggan.dart';

class DetailPelanggan extends StatefulWidget {
  final Pelanggan pelanggan;
  const DetailPelanggan({super.key, required this.pelanggan});

  @override
  State<DetailPelanggan> createState() => _DetailPelangganState();
}

class _DetailPelangganState extends State<DetailPelanggan> {
  late Pelanggan _p;

  @override
  void initState() {
    super.initState();
    _p = widget.pelanggan;
  }

  Future<void> _ubah() async {
    final hasil = await Navigator.push<Pelanggan>(
      context,
      MaterialPageRoute(builder: (_) => FormPelanggan(pelanggan: _p)),
    );
    if (hasil != null && mounted) setState(() => _p = hasil);
  }

  Future<void> _hapus() async {
    final setuju = await konfirmasiHapus(context);
    if (!setuju || !mounted) return;
    try {
      await LayananPelanggan().hapus(_p.id!);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (mounted) tampilPesan(context, 'Gagal menghapus data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pelanggan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.white,
            child: Column(
              children: [
                barisDetail('Nama', _p.nama),
                barisDetail('No. HP', _p.noHp),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _ubah,
                  icon: const Icon(Icons.edit),
                  label: const Text('Ubah'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _hapus,
                  icon: const Icon(Icons.delete),
                  label: const Text('Hapus'),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
