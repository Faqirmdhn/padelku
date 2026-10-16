import 'package:dio/dio.dart';

// GANTI dengan base URL project mockapi.io kamu.
// Akun A -> resource: lapangan, pelanggan
// Akun B -> resource: booking
// Kalau semua resource ada di satu akun, isi kedua URL dengan nilai yang sama.
const String urlAkunA = 'https://GANTI_ID_AKUN_A.mockapi.io/api/v1';
const String urlAkunB = 'https://GANTI_ID_AKUN_B.mockapi.io/api/v1';

class KlienApi {
  /// false selama URL mockapi masih placeholder.
  /// Saat false, aplikasi memakai data lokal (shared_preferences) dan tidak
  /// memanggil jaringan, sehingga tidak error DNS/host.
  static bool get apiSiap =>
      !urlAkunA.contains('GANTI_ID_AKUN_A') &&
      !urlAkunB.contains('GANTI_ID_AKUN_B');

  static Dio _buat(String url) => Dio(BaseOptions(
        baseUrl: url,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ));

  static final Dio akunA = _buat(urlAkunA);
  static final Dio akunB = _buat(urlAkunB);
}
