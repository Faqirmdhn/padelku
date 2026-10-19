import '../model/lapangan.dart';
import '../pembantu/penyimpanan_lokal.dart';

class LayananLapangan {
  final PenyimpananLokal _lokal = PenyimpananLokal('lapangan');

  Future<List<Lapangan>> daftar() async =>
      (await _lokal.daftar()).map(Lapangan.fromJson).toList();

  Future<Lapangan> ambil(String id) async {
    final data = await _lokal.ambil(id);
    if (data == null) throw const FormatException('Data tidak ditemukan');
    return Lapangan.fromJson(data);
  }

  Future<Lapangan> tambah(Lapangan data) async =>
      Lapangan.fromJson(await _lokal.tambah(data.toJson()));

  Future<Lapangan> ubah(Lapangan data, String id) async =>
      Lapangan.fromJson(await _lokal.ubah(id, data.toJson()));

  Future<void> hapus(String id) async {
    await _lokal.hapus(id);
  }
}
