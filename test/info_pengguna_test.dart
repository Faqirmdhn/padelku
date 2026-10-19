import 'package:flutter_application_1/layanan/layanan_lapangan.dart';
import 'package:flutter_application_1/model/lapangan.dart';
import 'package:flutter_application_1/pembantu/info_pengguna.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('logout menghapus sesi tapi data CRUD lokal tetap ada', () async {
    SharedPreferences.setMockInitialValues({});

    await InfoPengguna().simpan('admin', 'admin');
    await LayananLapangan().tambah(
        Lapangan(namaLapangan: 'Lap 1', jenis: 'indoor', hargaPerJam: 50000));

    await InfoPengguna().hapus();

    expect(await InfoPengguna().ambilToken(), isNull);
    expect(await InfoPengguna().ambilUsername(), isNull);
    expect((await LayananLapangan().daftar()).single.namaLapangan, 'Lap 1');
  });
}
