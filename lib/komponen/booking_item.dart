import 'package:flutter/material.dart';
import '../model/booking.dart';
import '../pembantu/alat.dart';

class BookingItem extends StatelessWidget {
  final Booking booking;
  final String namaLapangan;
  final String namaPelanggan;
  final VoidCallback onTap;

  const BookingItem({
    super.key,
    required this.booking,
    required this.namaLapangan,
    required this.namaPelanggan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: ListTile(
        onTap: onTap,
        isThreeLine: true,
        title: Text(namaLapangan,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '$namaPelanggan\n'
          '${booking.tanggal} • ${booking.jamMulai} • ${booking.durasiJam} jam\n'
          '${rupiah(booking.totalBayar)}',
        ),
        trailing: chipStatus(booking.status),
      ),
    );
  }
}
