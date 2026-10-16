import 'package:flutter/material.dart';
import '../../layanan/layanan_pelanggan.dart';
import '../../model/pelanggan.dart';
import '../../pembantu/alat.dart';

/// Dipakai untuk Tambah (pelanggan == null) dan Ubah (pelanggan != null).
class FormPelanggan extends StatefulWidget {
  final Pelanggan? pelanggan;
  const FormPelanggan({super.key, this.pelanggan});

  @override
  State<FormPelanggan> createState() => _FormPelangganState();
}

class _FormPelangganState extends State<FormPelanggan> {
  final _kunci = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _hpCtrl = TextEditingController();
  bool _menyimpan = false;

  bool get _modeUbah => widget.pelanggan != null;

  @override
  void initState() {
    super.initState();
    final p = widget.pelanggan;
    if (p != null) {
      _namaCtrl.text = p.nama;
      _hpCtrl.text = p.noHp;
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _hpCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_kunci.currentState!.validate()) return;
    setState(() => _menyimpan = true);
    final data =
        Pelanggan(nama: _namaCtrl.text.trim(), noHp: _hpCtrl.text.trim());
    try {
      final layanan = LayananPelanggan();
      final hasil = _modeUbah
          ? await layanan.ubah(data, widget.pelanggan!.id!)
          : await layanan.tambah(data);
      if (!mounted) return;
      Navigator.pop(context, hasil);
    } catch (_) {
      if (!mounted) return;
      setState(() => _menyimpan = false);
      tampilPesan(context, 'Gagal menyimpan data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_modeUbah ? 'Ubah Pelanggan' : 'Tambah Pelanggan')),
      body: Form(
        key: _kunci,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _namaCtrl,
              decoration: const InputDecoration(labelText: 'Nama'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Nama wajib diisi'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _hpCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'No. HP'),
              validator: (v) => (v == null || v.trim().length < 8)
                  ? 'Nomor HP tidak valid'
                  : null,
            ),
            const SizedBox(height: 24),
            TombolLebar(
              teks: _menyimpan ? 'Menyimpan...' : 'Simpan',
              onPressed: _menyimpan ? null : _simpan,
            ),
          ],
        ),
      ),
    );
  }
}
