import 'package:flutter/material.dart';
import '../pembantu/info_pengguna.dart';
import '../pembantu/tema.dart';
import '../tampilan/beranda.dart';
import '../tampilan/booking/halaman_booking.dart';
import '../tampilan/lapangan/halaman_lapangan.dart';
import '../tampilan/masuk.dart';
import '../tampilan/pelanggan/halaman_pelanggan.dart';

class MenuSamping extends StatelessWidget {
  /// beranda / lapangan / pelanggan / booking
  final String aktif;
  const MenuSamping({super.key, required this.aktif});

  void _ke(BuildContext context, String nama, Widget halaman) {
    Navigator.pop(context); // tutup drawer
    if (nama == aktif) return;
    if (nama == 'beranda') {
      Navigator.popUntil(context, (route) => route.isFirst);
      return;
    }
    final rute = MaterialPageRoute(builder: (_) => halaman);
    if (aktif == 'beranda') {
      Navigator.push(context, rute);
    } else {
      Navigator.pushReplacement(context, rute);
    }
  }

  Future<void> _keluar(BuildContext context) async {
    await InfoPengguna().hapus();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Masuk()),
      (route) => false,
    );
  }

  Widget _menu(BuildContext context, String nama, String teks, IconData ikon,
      Widget halaman) {
    return ListTile(
      leading: Icon(ikon),
      title: Text(teks),
      selected: aktif == nama,
      selectedColor: warnaUtama,
      onTap: () => _ke(context, nama, halaman),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: warnaUtama),
            accountName: Text('Admin'),
            accountEmail: Text('PadelKu'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: warnaAksen,
              child: Icon(Icons.sports_tennis, color: warnaUtama),
            ),
          ),
          _menu(context, 'beranda', 'Beranda', Icons.home, const Beranda()),
          _menu(context, 'lapangan', 'Data Lapangan', Icons.stadium,
              const HalamanLapangan()),
          _menu(context, 'pelanggan', 'Data Pelanggan', Icons.people,
              const HalamanPelanggan()),
          _menu(context, 'booking', 'Data Booking', Icons.event_available,
              const HalamanBooking()),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Keluar'),
            onTap: () => _keluar(context),
          ),
        ],
      ),
    );
  }
}
