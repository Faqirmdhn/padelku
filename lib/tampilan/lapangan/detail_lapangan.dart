import 'package:flutter/material.dart';
import '../../layanan/layanan_lapangan.dart';
import '../../model/lapangan.dart';
import '../../pembantu/alat.dart';
import 'form_lapangan.dart';

class DetailLapangan extends StatefulWidget {
  final Lapangan lapangan;
  const DetailLapangan({super.key, required this.lapangan});

  @override
  State<DetailLapangan> createState() => _DetailLapanganState();
}

class _DetailLapanganState extends State<DetailLapangan> {
  late Lapangan _l;

  @override
  void initState() {
    super.initState();
    _l = widget.lapangan;
  }

  Future<void> _ubah() async {
    final hasil = await Navigator.push<Lapangan>(
      context,
      MaterialPageRoute(builder: (_) => FormLapangan(lapangan: _l)),
    );
    if (hasil != null && mounted) setState(() => _l = hasil);
  }

  Future<void> _hapus() async {
    final setuju = await konfirmasiHapus(context);
    if (!setuju || !mounted) return;
    try {
      await LayananLapangan().hapus(_l.id!);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (mounted) tampilPesan(context, 'Gagal menghapus data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Lapangan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.white,
            child: Column(
              children: [
                barisDetail('Nama Lapangan', _l.namaLapangan),
                barisDetail('Jenis', _l.jenis),
                barisDetail('Harga per Jam', rupiah(_l.hargaPerJam)),
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
