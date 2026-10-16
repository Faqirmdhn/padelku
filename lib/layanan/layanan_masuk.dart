import '../pembantu/info_pengguna.dart';

/// Login dummy sesuai modul: admin / admin.
class LayananMasuk {
  Future<bool> masuk(String username, String password) async {
    if (username == 'admin' && password == 'admin') {
      await InfoPengguna().simpan('admin', username);
      return true;
    }
    return false;
  }
}
