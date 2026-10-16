import 'package:dio/dio.dart';
import '../model/booking.dart';
import '../pembantu/klien_api.dart';
import '../pembantu/penyimpanan_lokal.dart';

class LayananBooking {
  final PenyimpananLokal _lokal = PenyimpananLokal('booking');

  Future<List<Booking>> daftar() async {
    if (!KlienApi.apiSiap) {
      final data = await _lokal.daftar();
      return data.map(Booking.fromJson).toList();
    }
    try {
      final res = await KlienApi.akunB.get('/booking');
      return (res.data as List)
          .map((e) => Booking.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return []; // dianggap data kosong
      rethrow;
    }
  }

  Future<Booking> ambil(String id) async {
    if (!KlienApi.apiSiap) {
      final data = await _lokal.ambil(id);
      if (data == null) throw const FormatException('Data tidak ditemukan');
      return Booking.fromJson(data);
    }
    final res = await KlienApi.akunB.get('/booking/$id');
    return Booking.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Booking> tambah(Booking data) async {
    if (!KlienApi.apiSiap) {
      return Booking.fromJson(await _lokal.tambah(data.toJson()));
    }
    final res = await KlienApi.akunB.post('/booking', data: data.toJson());
    return Booking.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Booking> ubah(Booking data, String id) async {
    if (!KlienApi.apiSiap) {
      return Booking.fromJson(await _lokal.ubah(id, data.toJson()));
    }
    final res = await KlienApi.akunB.put('/booking/$id', data: data.toJson());
    return Booking.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> hapus(String id) async {
    if (!KlienApi.apiSiap) {
      await _lokal.hapus(id);
      return;
    }
    await KlienApi.akunB.delete('/booking/$id');
  }
}
