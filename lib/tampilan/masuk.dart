import 'package:flutter/material.dart';
import '../layanan/layanan_masuk.dart';
import '../pembantu/alat.dart';
import '../pembantu/tema.dart';
import 'beranda.dart';

class Masuk extends StatefulWidget {
  const Masuk({super.key});

  @override
  State<Masuk> createState() => _MasukState();
}

class _MasukState extends State<Masuk> {
  final _kunci = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _sembunyi = true;
  bool _proses = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _masuk() async {
    if (!_kunci.currentState!.validate()) return;
    setState(() => _proses = true);
    final berhasil = await LayananMasuk()
        .masuk(_usernameCtrl.text.trim(), _passwordCtrl.text);
    if (!mounted) return;
    setState(() => _proses = false);
    if (berhasil) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Beranda()),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          content: const Text('Username atau Password Tidak Valid'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB9EFC8), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _kunci,
                child: Column(
                  children: [
                    const Icon(Icons.sports_tennis,
                        size: 72, color: warnaUtama),
                    const SizedBox(height: 8),
                    const Text('PadelKu',
                        style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: warnaUtama)),
                    const Text('Login Admin'),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _usernameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Username wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _sembunyi,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_sembunyi
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () =>
                              setState(() => _sembunyi = !_sembunyi),
                        ),
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Password wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    TombolLebar(
                      teks: _proses ? 'Memproses...' : 'Masuk',
                      onPressed: _proses ? null : _masuk,
                    ),
                    const SizedBox(height: 12),
                    const Text('Gunakan admin / admin',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
