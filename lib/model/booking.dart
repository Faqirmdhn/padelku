import '../pembantu/alat.dart';

class Booking {
  String? id;
  String idLapangan;
  String idPelanggan;
  String tanggal; // yyyy-MM-dd
  String jamMulai; // HH:mm
  int durasiJam;
  int totalBayar;
  String status; // dipesan / selesai / dibatalkan

  Booking({
    this.id,
    required this.idLapangan,
    required this.idPelanggan,
    required this.tanggal,
    required this.jamMulai,
    required this.durasiJam,
    required this.totalBayar,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id']?.toString(),
        idLapangan: json['id_lapangan']?.toString() ?? '',
        idPelanggan: json['id_pelanggan']?.toString() ?? '',
        tanggal: json['tanggal']?.toString() ?? '',
        jamMulai: json['jam_mulai']?.toString() ?? '',
        durasiJam: keInt(json['durasi_jam']),
        totalBayar: keInt(json['total_bayar']),
        status: json['status']?.toString() ?? 'dipesan',
      );

  Map<String, dynamic> toJson() => {
        'id_lapangan': idLapangan,
        'id_pelanggan': idPelanggan,
        'tanggal': tanggal,
        'jam_mulai': jamMulai,
        'durasi_jam': durasiJam,
        'total_bayar': totalBayar,
        'status': status,
      };

  Booking salinStatus(String statusBaru) => Booking(
        id: id,
        idLapangan: idLapangan,
        idPelanggan: idPelanggan,
        tanggal: tanggal,
        jamMulai: jamMulai,
        durasiJam: durasiJam,
        totalBayar: totalBayar,
        status: statusBaru,
      );
}
