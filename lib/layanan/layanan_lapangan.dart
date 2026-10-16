import 'package:dio/dio.dart';
import '../model/lapangan.dart';
import '../pembantu/klien_api.dart';
import '../pembantu/penyimpanan_lokal.dart';

class LayananLapangan {
  final PenyimpananLokal _lokal = PenyimpananLokal('lapangan');

  Future<List<Lapangan>> daftar() async {
    if (!KlienApi.apiSiap) {
      final data = await _lokal.daftar();
      return data.map(Lapangan.fromJson).toList();
    }
    try {
      final res = await KlienApi.akunA.get('/lapangan');
      return (res.data as List)
          .map((e) => Lapangan.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return []; // dianggap data kosong
      rethrow;
    }
  }

  Future<Lapangan> ambil(String id) async {
    if (!KlienApi.apiSiap) {
      final data = await _lokal.ambil(id);
      if (data == null) throw const FormatException('Data tidak ditemukan');
      return Lapangan.fromJson(data);
    }
    final res = await KlienApi.akunA.get('/lapangan/$id');
    return Lapangan.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Lapangan> tambah(Lapangan data) async {
    if (!KlienApi.apiSiap) {
      return Lapangan.fromJson(await _lokal.tambah(data.toJson()));
    }
    final res = await KlienApi.akunA.post('/lapangan', data: data.toJson());
    return Lapangan.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Lapangan> ubah(Lapangan data, String id) async {
    if (!KlienApi.apiSiap) {
      return Lapangan.fromJson(await _lokal.ubah(id, data.toJson()));
    }
    final res = await KlienApi.akunA.put('/lapangan/$id', data: data.toJson());
    return Lapangan.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> hapus(String id) async {
    if (!KlienApi.apiSiap) {
      await _lokal.hapus(id);
      return;
    }
    await KlienApi.akunA.delete('/lapangan/$id');
  }
}
