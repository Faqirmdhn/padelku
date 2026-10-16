import '../pembantu/alat.dart';

class Lapangan {
  String? id;
  String namaLapangan;
  String jenis; // indoor / outdoor
  int hargaPerJam;

  Lapangan({
    this.id,
    required this.namaLapangan,
    required this.jenis,
    required this.hargaPerJam,
  });

  factory Lapangan.fromJson(Map<String, dynamic> json) => Lapangan(
        id: json['id']?.toString(),
        namaLapangan: json['nama_lapangan']?.toString() ?? '',
        jenis: json['jenis']?.toString() ?? 'indoor',
        hargaPerJam: keInt(json['harga_per_jam']),
      );

  Map<String, dynamic> toJson() => {
        'nama_lapangan': namaLapangan,
        'jenis': jenis,
        'harga_per_jam': hargaPerJam,
      };
}
