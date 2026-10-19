import '../model/booking.dart';
import '../pembantu/penyimpanan_lokal.dart';

class LayananBooking {
  final PenyimpananLokal _lokal = PenyimpananLokal('booking');

  Future<List<Booking>> daftar() async =>
      (await _lokal.daftar()).map(Booking.fromJson).toList();

  Future<Booking> ambil(String id) async {
    final data = await _lokal.ambil(id);
    if (data == null) throw const FormatException('Data tidak ditemukan');
    return Booking.fromJson(data);
  }

  Future<Booking> tambah(Booking data) async =>
      Booking.fromJson(await _lokal.tambah(data.toJson()));

  Future<Booking> ubah(Booking data, String id) async =>
      Booking.fromJson(await _lokal.ubah(id, data.toJson()));

  Future<void> hapus(String id) async {
    await _lokal.hapus(id);
  }
}
