import 'package:flutter_application_1/layanan/layanan_booking.dart';
import 'package:flutter_application_1/layanan/layanan_lapangan.dart';
import 'package:flutter_application_1/layanan/layanan_pelanggan.dart';
import 'package:flutter_application_1/model/booking.dart';
import 'package:flutter_application_1/model/lapangan.dart';
import 'package:flutter_application_1/model/pelanggan.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('CRUD lapangan jalan tanpa jaringan', () async {
    final layanan = LayananLapangan();
    expect(await layanan.daftar(), isEmpty);

    final l = await layanan.tambah(
        Lapangan(namaLapangan: 'Lap 1', jenis: 'indoor', hargaPerJam: 50000));
    expect(l.id, isNotNull);
    expect((await layanan.daftar()).length, 1);

    await layanan.ubah(
        Lapangan(
            namaLapangan: 'Lap 1 Utama',
            jenis: 'outdoor',
            hargaPerJam: 60000),
        l.id!);
    expect((await layanan.ambil(l.id!)).namaLapangan, 'Lap 1 Utama');

    await layanan.hapus(l.id!);
    expect(await layanan.daftar(), isEmpty);
  });

  test('CRUD pelanggan jalan tanpa jaringan', () async {
    final layanan = LayananPelanggan();
    final p =
        await layanan.tambah(Pelanggan(nama: 'Budi', noHp: '08123456789'));
    expect((await layanan.daftar()).single.nama, 'Budi');

    await layanan.ubah(Pelanggan(nama: 'Budi Santoso', noHp: '0812'), p.id!);
    expect((await layanan.ambil(p.id!)).nama, 'Budi Santoso');

    await layanan.hapus(p.id!);
    expect(await layanan.daftar(), isEmpty);
  });

  test('CRUD booking jalan tanpa jaringan', () async {
    final layanan = LayananBooking();
    final b = await layanan.tambah(Booking(
      idLapangan: '1',
      idPelanggan: '1',
      tanggal: '2026-10-20',
      jamMulai: '19:00',
      durasiJam: 2,
      totalBayar: 100000,
      status: 'dipesan',
    ));
    expect((await layanan.daftar()).single.durasiJam, 2);

    await layanan.ubah(b.salinStatus('selesai'), b.id!);
    expect((await layanan.ambil(b.id!)).status, 'selesai');

    await layanan.hapus(b.id!);
    expect(await layanan.daftar(), isEmpty);
  });

  test('ambil data yang tidak ada memunculkan error', () async {
    final layanan = LayananLapangan();
    expect(() => layanan.ambil('999'), throwsA(isA<FormatException>()));
  });
}
