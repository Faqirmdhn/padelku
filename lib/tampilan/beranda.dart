import 'package:flutter/material.dart';
import '../komponen/menu_samping.dart';
import '../layanan/layanan_booking.dart';
import '../layanan/layanan_lapangan.dart';
import '../layanan/layanan_pelanggan.dart';
import '../model/booking.dart';
import '../pembantu/alat.dart';
import '../pembantu/tema.dart';
import 'booking/halaman_booking.dart';
import 'lapangan/halaman_lapangan.dart';
import 'pelanggan/halaman_pelanggan.dart';

class Beranda extends StatefulWidget {
  const Beranda({super.key});

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  int? _jmlLapangan;
  int? _jmlPelanggan;
  int? _jmlBookingHariIni;
  bool _gagal = false;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    try {
      final hasil = await Future.wait([
        LayananLapangan().daftar(),
        LayananPelanggan().daftar(),
        LayananBooking().daftar(),
      ]);
      final booking = hasil[2] as List<Booking>;
      final hariIni = formatTanggal(DateTime.now());
      if (!mounted) return;
      setState(() {
        _jmlLapangan = hasil[0].length;
        _jmlPelanggan = hasil[1].length;
        _jmlBookingHariIni = booking.where((b) => b.tanggal == hariIni).length;
        _gagal = false;
      });
    } catch (_) {
      if (mounted) setState(() => _gagal = true);
    }
  }

  Widget _kartu(String judul, int? nilai, IconData ikon) {
    return Expanded(
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(ikon, color: warnaUtama),
              const SizedBox(height: 8),
              Text(
                nilai?.toString() ?? (_gagal ? '!' : '...'),
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: warnaUtama),
              ),
              const SizedBox(height: 4),
              Text(judul,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pintasan(String teks, IconData ikon, Widget halaman) {
    return Card(
      color: Colors.white,
      child: ListTile(
        leading: Icon(ikon, color: warnaUtama),
        title: Text(teks),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await Navigator.push(
              context, MaterialPageRoute(builder: (_) => halaman));
          _muat();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PadelKu')),
      drawer: const MenuSamping(aktif: 'beranda'),
      body: RefreshIndicator(
        onRefresh: _muat,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Halo, Admin',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _kartu('Total Lapangan', _jmlLapangan, Icons.stadium),
                _kartu('Total Pelanggan', _jmlPelanggan, Icons.people),
                _kartu('Booking Hari Ini', _jmlBookingHariIni,
                    Icons.event_available),
              ],
            ),
            if (_gagal)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Gagal memuat ringkasan. Periksa URL API, lalu tarik layar ke bawah.',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 16),
            _pintasan('Data Lapangan', Icons.stadium, const HalamanLapangan()),
            _pintasan(
                'Data Pelanggan', Icons.people, const HalamanPelanggan()),
            _pintasan('Data Booking', Icons.event_available,
                const HalamanBooking()),
          ],
        ),
      ),
    );
  }
}
