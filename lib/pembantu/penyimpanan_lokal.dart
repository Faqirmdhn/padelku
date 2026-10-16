import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Penyimpanan data sederhana di perangkat.
/// Dipakai sebagai pengganti API selama URL mockapi belum diisi,
/// supaya aplikasi tetap bisa dijalankan (data tersimpan di shared_preferences).
class PenyimpananLokal {
  final String kunci;
  PenyimpananLokal(this.kunci);

  String get _pref => 'lokal_$kunci';

  Future<List<Map<String, dynamic>>> _baca() async {
    final pref = await SharedPreferences.getInstance();
    final teks = pref.getString(_pref);
    if (teks == null || teks.isEmpty) return [];
    final data = jsonDecode(teks);
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<void> _tulis(List<Map<String, dynamic>> data) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(_pref, jsonEncode(data));
  }

  Future<List<Map<String, dynamic>>> daftar() => _baca();

  Future<Map<String, dynamic>?> ambil(String id) async {
    final data = await _baca();
    for (final item in data) {
      if (item['id']?.toString() == id) return item;
    }
    return null;
  }

  Future<Map<String, dynamic>> tambah(Map<String, dynamic> isi) async {
    final data = await _baca();
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final baru = <String, dynamic>{'id': id, ...isi};
    data.add(baru);
    await _tulis(data);
    return baru;
  }

  Future<Map<String, dynamic>> ubah(
      String id, Map<String, dynamic> isi) async {
    final data = await _baca();
    final baru = <String, dynamic>{'id': id, ...isi};
    final posisi = data.indexWhere((e) => e['id']?.toString() == id);
    if (posisi >= 0) {
      data[posisi] = baru;
    } else {
      data.add(baru);
    }
    await _tulis(data);
    return baru;
  }

  Future<void> hapus(String id) async {
    final data = await _baca();
    data.removeWhere((e) => e['id']?.toString() == id);
    await _tulis(data);
  }
}
