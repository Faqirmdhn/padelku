import '../model/pelanggan.dart';
import '../pembantu/penyimpanan_lokal.dart';

class LayananPelanggan {
  final PenyimpananLokal _lokal = PenyimpananLokal('pelanggan');

  Future<List<Pelanggan>> daftar() async =>
      (await _lokal.daftar()).map(Pelanggan.fromJson).toList();

  Future<Pelanggan> ambil(String id) async {
    final data = await _lokal.ambil(id);
    if (data == null) throw const FormatException('Data tidak ditemukan');
    return Pelanggan.fromJson(data);
  }

  Future<Pelanggan> tambah(Pelanggan data) async =>
      Pelanggan.fromJson(await _lokal.tambah(data.toJson()));

  Future<Pelanggan> ubah(Pelanggan data, String id) async =>
      Pelanggan.fromJson(await _lokal.ubah(id, data.toJson()));

  Future<void> hapus(String id) async {
    await _lokal.hapus(id);
  }
}
