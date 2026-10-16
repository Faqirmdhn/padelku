import 'package:flutter/material.dart';

// Palet hijau (terinspirasi aplikasi booking olahraga).
// Cukup ubah 4 warna ini untuk mengganti tema seluruh aplikasi.
const Color warnaUtama = Color(0xFF2E7D32); // hijau tua: tombol, teks aksen
const Color warnaHeader = Color(0xFF1FA64F); // hijau cerah: AppBar
const Color warnaAksen = Color(0xFFDFF5E3); // mint muda: ikon di atas hijau tua
const Color warnaLatar = Color(0xFFF1FAF3); // latar halaman

ThemeData buatTema() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: warnaUtama, primary: warnaUtama),
    scaffoldBackgroundColor: warnaLatar,
    appBarTheme: const AppBarTheme(
      backgroundColor: warnaHeader,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: warnaUtama,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: warnaUtama,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: warnaUtama, width: 2),
      ),
    ),
  );
}
