import 'package:flutter/material.dart';
import '../../layanan/layanan_booking.dart';
import '../../layanan/layanan_lapangan.dart';
import '../../layanan/layanan_pelanggan.dart';
import '../../model/booking.dart';
import '../../model/lapangan.dart';
import '../../model/pelanggan.dart';
import '../../pembantu/alat.dart';
import 'form_booking.dart';

class DetailBooking extends StatefulWidget {
  final Booking booking;
  const DetailBooking({super.key, required this.booking});

  @override
  State<DetailBooking> createState() => _DetailBookingState();
}

class _DetailBookingState extends State<DetailBooking> {
  late Booking _b;
  Lapangan? _lapangan;
  Pelanggan? _pelanggan;
  bool _memuat = true;

  @override
  void initState() {
    super.initState();
    _b = widget.booking;
    _muatRelasi();
  }

  Future<void> _muatRelasi() async {
    Lapangan? l;
    Pelanggan? p;
    try {
      l = await LayananLapangan().ambil(_b.idLapangan);
    } catch (_) {}
    try {
      p = await LayananPelanggan().ambil(_b.idPelanggan);
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _lapangan = l;
      _pelanggan = p;
      _memuat = false;
    });
  }

  Future<void> _ubah() async {
    final hasil = await Navigator.push<Booking>(
      context,
      MaterialPageRoute(builder: (_) => FormBooking(booking: _b)),
    );
    if (hasil != null && mounted) {
      setState(() {
        _b = hasil;
        _memuat = true;
      });
      _muatRelasi();
    }
  }

  Future<void> _ubahStatus(String baru) async {
    try {
      final hasil = await LayananBooking().ubah(_b.salinStatus(baru), _b.id!);
      if (!mounted) return;
      setState(() => _b = hasil);
    } catch (_) {
      if (mounted) tampilPesan(context, 'Gagal mengubah status');
    }
  }

  Future<void> _hapus() async {
    final setuju = await konfirmasiHapus(context);
    if (!setuju || !mounted) return;
    try {
      await LayananBooking().hapus(_b.id!);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (mounted) tampilPesan(context, 'Gagal menghapus data');
    }
  }

  @override
  Widget build(BuildContext context) {
    const tidakAda = 'Data tidak ditemukan';
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Booking')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.white,
            child: Column(
              children: [
                barisDetail('Lapangan',
                    _memuat ? 'Memuat...' : (_lapangan?.namaLapangan ?? tidakAda)),
                barisDetail('Pelanggan',
                    _memuat ? 'Memuat...' : (_pelanggan?.nama ?? tidakAda)),
                barisDetail('Tanggal', _b.tanggal),
                barisDetail('Jam Mulai', _b.jamMulai),
                barisDetail('Durasi', '${_b.durasiJam} jam'),
                barisDetail('Total Bayar', rupiah(_b.totalBayar)),
                ListTile(
                  title: const Text('Status',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  subtitle: Align(
                    alignment: Alignment.centerLeft,
                    child: chipStatus(_b.status),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_b.status == 'dipesan')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _ubahStatus('selesai'),
                    child: const Text('Tandai Selesai'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _ubahStatus('dibatalkan'),
                    child: const Text('Batalkan'),
                  ),
                ),
              ],
            ),
          if (_b.status == 'dipesan') const SizedBox(height: 12),
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
