import 'package:dio/dio.dart';
import '../model/pelanggan.dart';
import '../pembantu/klien_api.dart';
import '../pembantu/penyimpanan_lokal.dart';

class LayananPelanggan {
  final PenyimpananLokal _lokal = PenyimpananLokal('pelanggan');

  Future<List<Pelanggan>> daftar() async {
    if (!KlienApi.apiSiap) {
      final data = await _lokal.daftar();
      return data.map(Pelanggan.fromJson).toList();
    }
    try {
      final res = await KlienApi.akunA.get('/pelanggan');
      return (res.data as List)
          .map((e) => Pelanggan.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return []; // dianggap data kosong
      rethrow;
    }
  }

  Future<Pelanggan> ambil(String id) async {
    if (!KlienApi.apiSiap) {
      final data = await _lokal.ambil(id);
      if (data == null) throw const FormatException('Data tidak ditemukan');
      return Pelanggan.fromJson(data);
    }
    final res = await KlienApi.akunA.get('/pelanggan/$id');
    return Pelanggan.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Pelanggan> tambah(Pelanggan data) async {
    if (!KlienApi.apiSiap) {
      return Pelanggan.fromJson(await _lokal.tambah(data.toJson()));
    }
    final res = await KlienApi.akunA.post('/pelanggan', data: data.toJson());
    return Pelanggan.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Pelanggan> ubah(Pelanggan data, String id) async {
    if (!KlienApi.apiSiap) {
      return Pelanggan.fromJson(await _lokal.ubah(id, data.toJson()));
    }
    final res = await KlienApi.akunA.put('/pelanggan/$id', data: data.toJson());
    return Pelanggan.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> hapus(String id) async {
    if (!KlienApi.apiSiap) {
      await _lokal.hapus(id);
      return;
    }
    await KlienApi.akunA.delete('/pelanggan/$id');
  }
}
