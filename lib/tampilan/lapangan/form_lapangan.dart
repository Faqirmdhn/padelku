import 'package:flutter/material.dart';
import '../../layanan/layanan_lapangan.dart';
import '../../model/lapangan.dart';
import '../../pembantu/alat.dart';

/// Dipakai untuk Tambah (lapangan == null) dan Ubah (lapangan != null).
class FormLapangan extends StatefulWidget {
  final Lapangan? lapangan;
  const FormLapangan({super.key, this.lapangan});

  @override
  State<FormLapangan> createState() => _FormLapanganState();
}

class _FormLapanganState extends State<FormLapangan> {
  final _kunci = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _hargaCtrl = TextEditingController();
  String _jenis = 'indoor';
  bool _menyimpan = false;

  bool get _modeUbah => widget.lapangan != null;

  @override
  void initState() {
    super.initState();
    final l = widget.lapangan;
    if (l != null) {
      _namaCtrl.text = l.namaLapangan;
      _hargaCtrl.text = l.hargaPerJam.toString();
      _jenis = ['indoor', 'outdoor'].contains(l.jenis) ? l.jenis : 'indoor';
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _hargaCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_kunci.currentState!.validate()) return;
    setState(() => _menyimpan = true);
    final data = Lapangan(
      namaLapangan: _namaCtrl.text.trim(),
      jenis: _jenis,
      hargaPerJam: int.parse(_hargaCtrl.text.trim()),
    );
    try {
      final layanan = LayananLapangan();
      final hasil = _modeUbah
          ? await layanan.ubah(data, widget.lapangan!.id!)
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
      appBar:
          AppBar(title: Text(_modeUbah ? 'Ubah Lapangan' : 'Tambah Lapangan')),
      body: Form(
        key: _kunci,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _namaCtrl,
              decoration: const InputDecoration(labelText: 'Nama Lapangan'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Nama lapangan wajib diisi'
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _jenis,
              decoration: const InputDecoration(labelText: 'Jenis'),
              items: const [
                DropdownMenuItem(value: 'indoor', child: Text('indoor')),
                DropdownMenuItem(value: 'outdoor', child: Text('outdoor')),
              ],
              onChanged: (v) => setState(() => _jenis = v ?? 'indoor'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _hargaCtrl,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Harga per Jam (Rp)'),
              validator: (v) {
                final angka = int.tryParse((v ?? '').trim());
                if (angka == null || angka <= 0) {
                  return 'Masukkan harga yang valid';
                }
                return null;
              },
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
