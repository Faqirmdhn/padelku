import 'package:flutter/material.dart';
import '../../komponen/booking_item.dart';
import '../../komponen/menu_samping.dart';
import '../../layanan/layanan_booking.dart';
import '../../layanan/layanan_lapangan.dart';
import '../../layanan/layanan_pelanggan.dart';
import '../../model/booking.dart';
import '../../model/lapangan.dart';
import '../../model/pelanggan.dart';
import '../../pembantu/alat.dart';
import 'detail_booking.dart';
import 'form_booking.dart';

class _DataBooking {
  final List<Booking> booking;
  final Map<String, Lapangan> lapangan;
  final Map<String, Pelanggan> pelanggan;
  _DataBooking(this.booking, this.lapangan, this.pelanggan);
}

class HalamanBooking extends StatefulWidget {
  const HalamanBooking({super.key});

  @override
  State<HalamanBooking> createState() => _HalamanBookingState();
}

class _HalamanBookingState extends State<HalamanBooking> {
  late Future<_DataBooking> _data;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  void _muat() {
    _data = _ambil();
  }

  Future<_DataBooking> _ambil() async {
    final hasil = await Future.wait([
      LayananBooking().daftar(),
      LayananLapangan().daftar(),
      LayananPelanggan().daftar(),
    ]);
    final booking = hasil[0] as List<Booking>;
    final lap = hasil[1] as List<Lapangan>;
    final pel = hasil[2] as List<Pelanggan>;
    // Terbaru di atas
    booking.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    return _DataBooking(
      booking,
      {for (final l in lap) l.id ?? '': l},
      {for (final p in pel) p.id ?? '': p},
    );
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
      appBar: AppBar(title: const Text('Data Booking')),
      drawer: const MenuSamping(aktif: 'booking'),
      body: FutureBuilder<_DataBooking>(
        future: _data,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || snap.data == null) {
            return tampilanGagal(() => setState(_muat));
          }
          final data = snap.data!;
          if (data.booking.isEmpty) {
            return const Center(child: Text('Belum ada data booking'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: data.booking.length,
            itemBuilder: (context, i) {
              final b = data.booking[i];
              return BookingItem(
                booking: b,
                namaLapangan:
                    data.lapangan[b.idLapangan]?.namaLapangan ??
                        'Data tidak ditemukan',
                namaPelanggan:
                    data.pelanggan[b.idPelanggan]?.nama ??
                        'Data tidak ditemukan',
                onTap: () => _buka(DetailBooking(booking: b)),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _buka(const FormBooking()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
