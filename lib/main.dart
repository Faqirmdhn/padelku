import 'package:flutter/material.dart';
import 'pembantu/info_pengguna.dart';
import 'pembantu/tema.dart';
import 'tampilan/beranda.dart';
import 'tampilan/masuk.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final token = await InfoPengguna().ambilToken();
  runApp(MaterialApp(
    title: 'PadelKu',
    debugShowCheckedModeBanner: false,
    theme: buatTema(),
    home: token == null ? const Masuk() : const Beranda(),
  ));
}
