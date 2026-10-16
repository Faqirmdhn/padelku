import 'package:flutter/material.dart';
import '../../komponen/lapangan_item.dart';
import '../../komponen/menu_samping.dart';
import '../../layanan/layanan_lapangan.dart';
import '../../model/lapangan.dart';
import '../../pembantu/alat.dart';
import 'detail_lapangan.dart';
import 'form_lapangan.dart';

class HalamanLapangan extends StatefulWidget {
  const HalamanLapangan({super.key});

  @override
  State<HalamanLapangan> createState() => _HalamanLapanganState();
}

class _HalamanLapanganState extends State<HalamanLapangan> {
  late Future<List<Lapangan>> _data;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  void _muat() {
    _data = LayananLapangan().daftar();
  }

  Future<void> _buka(Widget halaman) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => halaman));
    if (!mounted) return;
    setState(_muat);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Lapangan')),
      drawer: const MenuSamping(aktif: 'lapangan'),
      body: FutureBuilder<List<Lapangan>>(
        future: _data,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return tampilanGagal(() => setState(_muat));
          }
          final daftar = snap.data ?? [];
          if (daftar.isEmpty) {
            return const Center(child: Text('Belum ada data lapangan'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: daftar.length,
            itemBuilder: (context, i) => LapanganItem(
              lapangan: daftar[i],
              onTap: () => _buka(DetailLapangan(lapangan: daftar[i])),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _buka(const FormLapangan()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
