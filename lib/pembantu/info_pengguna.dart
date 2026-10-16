import 'package:shared_preferences/shared_preferences.dart';

class InfoPengguna {
  static const _kToken = 'token';
  static const _kUsername = 'username';

  Future<void> simpan(String token, String username) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(_kToken, token);
    await pref.setString(_kUsername, username);
  }

  Future<String?> ambilToken() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(_kToken);
  }

  Future<String?> ambilUsername() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(_kUsername);
  }

  /// Dipakai saat Keluar (logout).
  Future<void> hapus() async {
    final pref = await SharedPreferences.getInstance();
    await pref.clear();
  }
}
