import 'package:flutter/material.dart';
import '../../layanan/layanan_booking.dart';
import '../../layanan/layanan_lapangan.dart';
import '../../layanan/layanan_pelanggan.dart';
import '../../model/booking.dart';
import '../../model/lapangan.dart';
import '../../model/pelanggan.dart';
import '../../pembantu/alat.dart';
import '../../pembantu/tema.dart';

/// Dipakai untuk Tambah (booking == null) dan Ubah (booking != null).
class FormBooking extends StatefulWidget {
  final Booking? booking;
  const FormBooking({super.key, this.booking});

  @override
  State<FormBooking> createState() => _FormBookingState();
}

class _FormBookingState extends State<FormBooking> {
  final _kunci = GlobalKey<FormState>();
  List<Lapangan> _daftarLapangan = [];
  List<Pelanggan> _daftarPelanggan = [];
  String? _idLapangan;
  String? _idPelanggan;
  DateTime _tanggal = DateTime.now();
  TimeOfDay _jam = const TimeOfDay(hour: 19, minute: 0);
  int _durasi = 1;
  String _status = 'dipesan';
  bool _memuat = true;
  bool _gagal = false;
  bool _menyimpan = false;

  bool get _modeUbah => widget.booking != null;

  /// total_bayar = durasi x harga_per_jam lapangan terpilih
  int get _total {
    for (final l in _daftarLapangan) {
      if (l.id == _idLapangan) return l.hargaPerJam * _durasi;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    final b = widget.booking;
    if (b != null) {
      _idLapangan = b.idLapangan;
      _idPelanggan = b.idPelanggan;
      _tanggal = DateTime.tryParse(b.tanggal) ?? DateTime.now();
      final bagian = b.jamMulai.split(':');
      if (bagian.length == 2) {
        _jam = TimeOfDay(
          hour: int.tryParse(bagian[0]) ?? 19,
          minute: int.tryParse(bagian[1]) ?? 0,
        );
      }
      _durasi = b.durasiJam < 1 ? 1 : b.durasiJam;
      if (['dipesan', 'selesai', 'dibatalkan'].contains(b.status)) {
        _status = b.status;
      }
    }
    _muatPilihan();
  }

  Future<void> _muatPilihan() async {
    try {
      final l = await LayananLapangan().daftar();
      final p = await LayananPelanggan().daftar();
      if (!mounted) return;
      setState(() {
        _daftarLapangan = l;
        _daftarPelanggan = p;
        // Hindari error dropdown jika data lama sudah dihapus
        if (!l.any((e) => e.id == _idLapangan)) _idLapangan = null;
        if (!p.any((e) => e.id == _idPelanggan)) _idPelanggan = null;
        _memuat = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _memuat = false;
          _gagal = true;
        });
      }
    }
  }

  Future<void> _pilihTanggal() async {
    final hasil = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (hasil != null && mounted) setState(() => _tanggal = hasil);
  }

  Future<void> _pilihJam() async {
    final hasil = await showTimePicker(context: context, initialTime: _jam);
    if (hasil != null && mounted) setState(() => _jam = hasil);
  }

  Future<void> _simpan() async {
    if (!_kunci.currentState!.validate()) return;
    setState(() => _menyimpan = true);
    final data = Booking(
      idLapangan: _idLapangan!,
      idPelanggan: _idPelanggan!,
      tanggal: formatTanggal(_tanggal),
      jamMulai: formatJam(_jam),
      durasiJam: _durasi,
      totalBayar: _total,
      status: _status,
    );
    try {
      final layanan = LayananBooking();
      final hasil = _modeUbah
          ? await layanan.ubah(data, widget.booking!.id!)
          : await layanan.tambah(data);
      if (!mounted) return;
      Navigator.pop(context, hasil);
    } catch (_) {
      if (!mounted) return;
      setState(() => _menyimpan = false);
      tampilPesan(context, 'Gagal menyimpan data');
    }
  }

  Widget _kolomPilih(
      String label, String nilai, IconData ikon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, suffixIcon: Icon(ikon)),
        child: Text(nilai),
      ),
    );
  }

  Widget _isiForm() {
    return Form(
      key: _kunci,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: _idLapangan,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Lapangan'),
            items: _daftarLapangan
                .map((l) => DropdownMenuItem<String>(
                      value: l.id,
                      child: Text(
                          '${l.namaLapangan} • ${rupiah(l.hargaPerJam)}/jam'),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _idLapangan = v),
            validator: (v) => v == null ? 'Pilih lapangan' : null,
          ),
          if (_daftarLapangan.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text('Belum ada data lapangan. Tambahkan dulu.',
                  style: TextStyle(color: Colors.red, fontSize: 12)),
            ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _idPelanggan,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Pelanggan'),
            items: _daftarPelanggan
                .map((p) => DropdownMenuItem<String>(
                      value: p.id,
                      child: Text(p.nama),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _idPelanggan = v),
            validator: (v) => v == null ? 'Pilih pelanggan' : null,
          ),
          if (_daftarPelanggan.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text('Belum ada data pelanggan. Tambahkan dulu.',
                  style: TextStyle(color: Colors.red, fontSize: 12)),
            ),
          const SizedBox(height: 16),
          _kolomPilih('Tanggal', formatTanggal(_tanggal),
              Icons.calendar_today, _pilihTanggal),
          const SizedBox(height: 16),
          _kolomPilih(
              'Jam Mulai', formatJam(_jam), Icons.access_time, _pilihJam),
          const SizedBox(height: 16),
          InputDecorator(
            decoration: const InputDecoration(labelText: 'Durasi'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed:
                      _durasi > 1 ? () => setState(() => _durasi--) : null,
                ),
                Text('$_durasi jam',
                    style: const TextStyle(fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed:
                      _durasi < 12 ? () => setState(() => _durasi++) : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: const [
              DropdownMenuItem(value: 'dipesan', child: Text('dipesan')),
              DropdownMenuItem(value: 'selesai', child: Text('selesai')),
              DropdownMenuItem(value: 'dibatalkan', child: Text('dibatalkan')),
            ],
            onChanged: (v) => setState(() => _status = v ?? 'dipesan'),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.white,
            child: ListTile(
              title: const Text('Total Bayar'),
              trailing: Text(
                rupiah(_total),
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: warnaUtama),
              ),
            ),
          ),
          const SizedBox(height: 24),
          TombolLebar(
            teks: _menyimpan ? 'Menyimpan...' : 'Simpan',
            onPressed: _menyimpan ? null : _simpan,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget isi;
    if (_memuat) {
      isi = const Center(child: CircularProgressIndicator());
    } else if (_gagal) {
      isi = tampilanGagal(() {
        setState(() {
          _memuat = true;
          _gagal = false;
        });
        _muatPilihan();
      });
    } else {
      isi = _isiForm();
    }
    return Scaffold(
      appBar:
          AppBar(title: Text(_modeUbah ? 'Ubah Booking' : 'Tambah Booking')),
      body: isi,
    );
  }
}
