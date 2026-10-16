import 'package:flutter/material.dart';
import '../../komponen/menu_samping.dart';
import '../../komponen/pelanggan_item.dart';
import '../../layanan/layanan_pelanggan.dart';
import '../../model/pelanggan.dart';
import '../../pembantu/alat.dart';
import 'detail_pelanggan.dart';
import 'form_pelanggan.dart';

class HalamanPelanggan extends StatefulWidget {
  const HalamanPelanggan({super.key});

  @override
  State<HalamanPelanggan> createState() => _HalamanPelangganState();
}

class _HalamanPelangganState extends State<HalamanPelanggan> {
  late Future<List<Pelanggan>> _data;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  void _muat() {
    _data = LayananPelanggan().daftar();
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
      appBar: AppBar(title: const Text('Data Pelanggan')),
      drawer: const MenuSamping(aktif: 'pelanggan'),
      body: FutureBuilder<List<Pelanggan>>(
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
            return const Center(child: Text('Belum ada data pelanggan'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: daftar.length,
            itemBuilder: (context, i) => PelangganItem(
              pelanggan: daftar[i],
              onTap: () => _buka(DetailPelanggan(pelanggan: daftar[i])),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _buka(const FormPelanggan()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
