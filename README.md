# PadelKu (Flutter, versi Admin)

Aplikasi admin untuk mengelola **lapangan**, **pelanggan**, dan **booking** padel
(tema hijau). CRUD lengkap untuk 3 tabel, **seluruh data disimpan lokal di
perangkat** (shared_preferences) sehingga jalan tanpa internet dan tanpa backend.
Login dummy: `admin` / `admin`.

---

## 1. Stack dan Dependensi

| Bagian | Teknologi |
| --- | --- |
| Framework | Flutter 3.x (Dart SDK `^3.11.5`) |
| State management | `StatefulWidget` + `FutureBuilder` (tanpa package tambahan) |
| Penyimpanan data | `shared_preferences ^2.3.3` (CRUD lokal + sesi login) |
| Backend | tidak ada — seluruh CRUD lokal |
| Lint | `flutter_lints ^6.0.0` (`analysis_options.yaml`) |
| Theme | Material 3 (`useMaterial3: true`) |

---

## 2. Struktur Proyek

```
lib/
├── main.dart                    # entry point + cek sesi login
├── komponen/                    # widget tampilan yang dipakai berulang
│   ├── booking_item.dart        # kartu satu baris booking
│   ├── lapangan_item.dart       # kartu satu baris lapangan
│   ├── pelanggan_item.dart      # kartu satu baris pelanggan
│   └── menu_samping.dart        # drawer navigasi
├── layanan/                     # lapisan akses data (satu file per tabel)
│   ├── layanan_booking.dart
│   ├── layanan_lapangan.dart
│   ├── layanan_pelanggan.dart
│   └── layanan_masuk.dart       # login dummy
├── model/                       # objek data + konversi JSON
│   ├── booking.dart
│   ├── lapangan.dart
│   └── pelanggan.dart
├── pembantu/                    # utilitas bersama
│   ├── penyimpanan_lokal.dart   # CRUD lokal (read/write JSON per tabel)
│   ├── info_pengguna.dart       # simpan/hapus sesi login
│   ├── alat.dart                # rupiah, format tanggal/jam, dialog, snackbar
│   └── tema.dart                # 4 konstanta warna + buatTema()
└── tampilan/                    # halaman (screen)
    ├── masuk.dart               # login
    ├── beranda.dart             # ringkasan + pintasan
    ├── lapangan/
    │   ├── halaman_lapangan.dart    # daftar
    │   ├── detail_lapangan.dart     # detail + ubah/hapus
    │   └── form_lapangan.dart       # tambah/ubah
    ├── pelanggan/
    │   ├── halaman_pelanggan.dart
    │   ├── detail_pelanggan.dart
    │   └── form_pelanggan.dart
    └── booking/
        ├── halaman_booking.dart
        ├── detail_booking.dart
        └── form_booking.dart

test/
├── widget_test.dart             # layar login tampil
└── layanan_lokal_test.dart      # CRUD lokal untuk 3 tabel
```

---

## 3. Arsitektur Aplikasi

Pola **layered architecture** sederhana, satu arah ke bawah. UI tidak pernah
memanggil `SharedPreferences` langsung — selalu lewat `layanan/`.

```
┌──────────────────────────────────────────────┐
│ tampilan/  (halaman & state UI)              │
│   FutureBuilder -> Future<T>                 │
└──────────────────┬───────────────────────────┘
                   │ memanggil
┌──────────────────▼───────────────────────────┐
│ layanan/  (satu kelas per resource)          │
│   daftar / ambil / tambah / ubah / hapus     │
└──────────────────┬───────────────────────────┘
                   │
┌──────────────────▼───────────────────────────┐
│ pembantu/penyimpanan_lokal.dart              │
│   shared_preferences, JSON array per tabel   │
│   kunci: lokal_lapangan, lokal_pelanggan,    │
│          lokal_booking                       │
└──────────────────┬───────────────────────────┘
                   │ jsonEncode / jsonDecode
┌──────────────────▼───────────────────────────┐
│ model/  Lapangan, Pelanggan, Booking         │
│   fromJson()  <-  toJson()                   │
└──────────────────────────────────────────────┘
```

**Tanggung jawab tiap lapisan**

| Lapisan | Tugas | Boleh tahu soal |
| --- | --- | --- |
| `tampilan/` | merender, validasi form, navigasi, loading/error state | hanya model & layanan |
| `komponen/` | widget kartu/menu yang dipakai lintas halaman | hanya model |
| `layanan/` | membalik model ↔ penyimpanan lokal, menangani data tak ada | model + penyimpanan |
| `model/` | struktur data, mapping JSON, nilai default | tidak tahu UI/penyimpanan |
| `pembantu/` | penyimpanan, sesi, utilitas, tema | tidak tahu UI |

Alasan pemisahan ini: mengganti tempat penyimpanan (mis. ke database SQLite
atau REST) cukup mengubah `layanan/` + `pembantu/penyimpanan_lokal.dart`;
mengganti gaya UI cukup mengubah `tampilan/` dan `komponen/`.

---

## 4. Cara Kerja

### 4.1 Alur saat aplikasi dibuka

`lib/main.dart:7`

1. `WidgetsFlutterBinding.ensureInitialized()` — wajib sebelum `SharedPreferences`.
2. `InfoPengguna().ambilToken()` membaca sesi login.
3. `MaterialApp.home` dipilih otomatis:
   - token `null` → `Masuk` (layar login)
   - token ada → `Beranda` (langsung, tanpa login ulang)
4. `theme: buatTema()` dari `pembantu/tema.dart`.

### 4.2 Autentikasi (dummy)

- `tampilan/masuk.dart` → `LayananMasuk().masuk(user, pass)`.
- `layanan/layanan_masuk.dart` menerima hanya `admin` / `admin`, lalu
  `InfoPengguna().simpan('admin', 'admin')` menulis token + username.
- Gagal → `AlertDialog` "Username atau Password Tidak Valid".
- Berhasil → `pushReplacement(Beranda)`.
- Keluar → `MenuSamping._keluar()`: `InfoPengguna().hapus()` lalu
  `pushAndRemoveUntil(Masuk)`.

> **Catatan:** logout (`InfoPengguna().hapus()`) hanya menghapus sesi
> `token` + `username`; data CRUD lokal tetap tersimpan (dibuktikan
> `test/info_pengguna_test.dart`).

### 4.3 Penyimpanan data lokal

`lib/pembantu/penyimpanan_lokal.dart`

| Metode | Kerja |
| --- | --- |
| `daftar()` | baca JSON array dari prefs → `List<Map<String, dynamic>>` |
| `ambil(id)` | cari item dengan `id`, `null` bila tidak ada |
| `tambah(isi)` | buat `id` baru dari `DateTime.now().microsecondsSinceEpoch`, simpan |
| `ubah(id, isi)` | timpa item pada posisi `id`; bila tidak ada, tambahkan |
| `hapus(id)` | buang item dari array lalu tulis ulang |

Detail teknis:

- Satu tabel = satu kunci prefs: `lokal_lapangan`, `lokal_pelanggan`,
  `lokal_booking`, nilai berupa string JSON array.
- Semua operasi baca → ubah → tulis ulang seluruh array (data kecil, aman).
- Karena operasi async, `layanan/` selalu mengembalikan `Future`.
- Data bertahan selama aplikasi tidak di-uninstall dan tidak logout.

### 4.4 Alur CRUD (contoh tambah data)

```
FormLapangan._simpan()
   ├─ _kunci.currentState!.validate()       // validasi form, batal jika gagal
   ├─ Lapangan(nama..., jenis..., harga...) // susun objek model
   ├─ LayananLapangan().tambah(objek)
   │     ├─ objek.toJson()
   │     ├─ _lokal.tambah(json)  -> tambah id, tulis ke prefs
   │     └─ fromJson(hasil)                 // hasil sudah berisi id
   └─ Navigator.pop(context, hasil)         // kirim balik ke halaman asal
Halaman asal: setState(_muat) → FutureBuilder reload daftar
```

Pola `pop(context, hasil)` dipakai di semua detail & form, sehingga daftar
selalu dimuat ulang setelah kembali (`_buka()` → `setState(_muat)`).

### 4.5 Navigasi

| Dari | Ke | Cara |
| --- | --- | --- |
| Masuk | Beranda | `pushReplacement` |
| Beranda | Halaman data | `push` dari kartu pintasan |
| Drawer (`MenuSamping`) | sesama halaman data | `pushReplacement` (stack tidak menumpuk) |
| Drawer | Beranda | `popUntil(isFirst)` |
| Daftar | Detail | `push(DetailX(data))` |
| Daftar | Form tambah | `push(FormX())` via FAB `+` |
| Detail | Form ubah | `push(FormX(data))` → hasil `pop` |
| Detail | Hapus | `konfirmasiHapus()` → `hapus()` → `pop(true)` |
| Keluar | Masuk | `pushAndRemoveUntil` (hapus seluruh stack) |

Halaman berada di stack yang sama (bukan rute bernama / `onGenerateRoute`).

---

## 5. Daftar Halaman dan Bagiannya

### 5.1 `Masuk` — `tampilan/masuk.dart`

| Bagian | Isi |
| --- | --- |
| Latar | gradien hijau muda → putih |
| Header | ikon `sports_tennis`, judul "PadelKu", subjudul "Login Admin" |
| Form | `Username`, `Password` (toggle lihat/sandi), validator wajib isi |
| Aksi | tombol lebar "Masuk" / "Memproses..." |
| Bantuan | teks "Gunakan admin / admin" |
| Error | dialog "Username atau Password Tidak Valid" |

### 5.2 `Beranda` — `tampilan/beranda.dart`

| Bagian | Isi |
| --- | --- |
| AppBar | "PadelKu" + drawer |
| Sapaan | "Halo, Admin" |
| Kartu ringkasan | Total Lapangan / Total Pelanggan / Booking Hari Ini (dihitung `Future.wait` + filter `tanggal == hari ini`) |
| Pesan gagal | teks merah bila salah satu `daftar()` melempar error |
| Pintasan | 3 kartu menuju halaman lapangan, pelanggan, booking |
| Refresh | ditarik ke bawah (`RefreshIndicator`) → `_muat()` |

### 5.3 `MenuSamping` — `komponen/menu_samping.dart`

| Bagian | Isi |
| --- | --- |
| Header | `UserAccountsDrawerHeader` hijau: Admin / PadelKu / ikon raket |
| Menu | Beranda, Data Lapangan, Data Pelanggan, Data Booking (menu aktif ditandai warna) |
| Aksi | Divider lalu **Keluar** (hapus sesi → layar login) |

### 5.4 `HalamanLapangan` — `tampilan/lapangan/halaman_lapangan.dart`

| Bagian | Isi |
| --- | --- |
| Body | `FutureBuilder<List<Lapangan>>`; loading `CircularProgressIndicator`; gagal → `tampilanGagal()` (tombol Coba Lagi); kosong → "Belum ada data lapangan" |
| Item | `LapanganItem`: avatar raket, nama, `Rp x/jam`, chip `indoor/outdoor` |
| FAB | `+` → `FormLapangan` (tambah) |
| Klik item | → `DetailLapangan` |

### 5.5 `DetailLapangan` — `tampilan/lapangan/detail_lapangan.dart`

| Bagian | Isi |
| --- | --- |
| Kartu detail | `barisDetail` untuk Nama Lapangan, Jenis, Harga per Jam |
| Aksi | **Ubah** (hijau) → `FormLapangan`, **Hapus** (merah) → konfirmasi → hapus → `pop(true)` |
| Error hapus | snackbar "Gagal menghapus data" |

### 5.6 `FormLapangan` — `tampilan/lapangan/form_lapangan.dart`

Dipakai untuk **Tambah** (`lapangan == null`) dan **Ubah** (`lapangan != null`),
judul AppBar berubah otomatis.

| Field | Aturan |
| --- | --- |
| Nama Lapangan | wajib, teks |
| Jenis | dropdown `indoor` / `outdoor` (default `indoor`) |
| Harga per Jam | wajib, angka > 0 |
| Tombol | `TombolLebar` "Simpan" / "Menyimpan...", ganda klik dicegah |

### 5.7 `HalamanPelanggan` / `DetailPelanggan` / `FormPelanggan`

Pola sama dengan lapangan.

| Halaman | Bagian |
| --- | --- |
| Daftar | `PelangganItem`: avatar huruf pertama nama, nama, no. HP |
| Detail | baris Nama dan No. HP + tombol Ubah/Hapus |
| Form | Nama (wajib), No. HP (wajib, minimal 8 karakter) |

### 5.8 `HalamanBooking` — `tampilan/booking/halaman_booking.dart`

Satu-satunya halaman yang menggabungkan 3 tabel.

| Bagian | Isi |
| --- | --- |
| Muat data | `Future.wait` booking + lapangan + pelanggan |
| Penyusunan | dua `Map<String, X>` untuk pencarian `id → objek` (join di sisi UI) |
| Urutan | `booking.sort` tanggal terbaru di atas |
| Item | `BookingItem`: nama lapangan, nama pelanggan, tanggal • jam • durasi, total, chip status |
| Relasi hilang | teks "Data tidak ditemukan" |
| FAB | `+` → `FormBooking` |

### 5.9 `DetailBooking` — `tampilan/booking/detail_booking.dart`

| Bagian | Isi |
| --- | --- |
| Muat relasi | `LayananLapangan().ambil(idLapangan)` dan `LayananPelanggan().ambil(idPelanggan)` — dua pembacaan terpisah, keduanya dibungkus `try/catch` |
| Kartu detail | Lapangan, Pelanggan, Tanggal, Jam Mulai, Durasi, Total Bayar (`rupiah`), Status (chip) |
| Ubah status | hanya saat `dipesan`: **Tandai Selesai** → `selesai`, **Batalkan** → `dibatalkan`, langsung `layananBooking.ubah()` dan state diperbarui |
| Aksi | **Ubah** → `FormBooking`, **Hapus** → konfirmasi → `pop(true)` |

### 5.10 `FormBooking` — `tampilan/booking/form_booking.dart`

| Field | Aturan |
| --- | --- |
| Lapangan | dropdown dari `daftar()`, wajib pilih, teks `nama • Rp x/jam` |
| Pelanggan | dropdown dari `daftar()`, wajib pilih |
| Tanggal | `showDatePicker` → format `yyyy-MM-dd` (default hari ini) |
| Jam Mulai | `showTimePicker` → format `HH:mm` (default 19:00) |
| Durasi | tombol − / +, 1–12 jam |
| Status | dropdown `dipesan` / `selesai` / `dibatalkan` |
| Total Bayar | dihitung otomatis `harga_per_jam × durasi` |
| Data hilang | pilihan yang id-nya sudah tidak ada di-set `null` lagi supaya dropdown tidak error |
| Opsi kosong | pesan merah "Belum ada data lapangan/pelanggan. Tambahkan dulu." |

### 5.11 Status UI yang dipakai bersama

Semua halaman daftar memakai tiga state yang sama:

1. `connectionState != done` → `CircularProgressIndicator`
2. `snap.hasError` → `tampilanGagal(ulang)` (ikon `cloud_off` + "Coba Lagi")
3. daftar kosong → `Center(Text('Belum ada data ...'))`

---

## 6. Model dan Data Tersimpan

Struktur field sama dengan bentuk yang disimpan di prefs (JSON array).

### `lapangan` — `model/lapangan.dart` — kunci `lokal_lapangan`

| JSON | Dart | Tipe | Default |
| --- | --- | --- | --- |
| `id` | `id` | `String?` | dibuat `PenyimpananLokal` (timestamp microdetik) |
| `nama_lapangan` | `namaLapangan` | `String` | `''` |
| `jenis` | `jenis` | `String` | `'indoor'` |
| `harga_per_jam` | `hargaPerJam` | `int` (via `keInt`) | `0` |

### `pelanggan` — `model/pelanggan.dart` — kunci `lokal_pelanggan`

| JSON | Dart | Tipe | Default |
| --- | --- | --- | --- |
| `id` | `id` | `String?` | otomatis |
| `nama` | `nama` | `String` | `''` |
| `no_hp` | `noHp` | `String` | `''` |

### `booking` — `model/booking.dart` — kunci `lokal_booking`

| JSON | Dart | Tipe | Default |
| --- | --- | --- | --- |
| `id` | `id` | `String?` | otomatis |
| `id_lapangan` | `idLapangan` | `String` | `''` |
| `id_pelanggan` | `idPelanggan` | `String` | `''` |
| `tanggal` | `tanggal` | `String` (`yyyy-MM-dd`) | `''` |
| `jam_mulai` | `jamMulai` | `String` (`HH:mm`) | `''` |
| `durasi_jam` | `durasiJam` | `int` | `0` |
| `total_bayar` | `totalBayar` | `int` | `0` |
| `status` | `status` | `String` | `'dipesan'` |

Aturan model:

- `toJson()` **tidak** mengirim `id`; `id` selalu ditambahkan oleh
  `PenyimpananLokal` saat `tambah()`.
- `fromJson()` tidak pernah melempar: nilai hilang memakai default, angka lewat
  `keInt()` (aman terhadap nilai `String`).
- `Booking.salinStatus()` menyalin seluruh field, mengganti status saja —
  dipakai tombol ubah status di detail.

---

## 7. Komponen dan Helper

### `komponen/`

| File | Widget | Dipakai di |
| --- | --- | --- |
| `lapangan_item.dart` | `LapanganItem` | daftar lapangan |
| `pelanggan_item.dart` | `PelangganItem` | daftar pelanggan |
| `booking_item.dart` | `BookingItem` | daftar booking (butuh `namaLapangan` & `namaPelanggan` siap pakai) |
| `menu_samping.dart` | `MenuSamping` | drawer semua halaman |

### `pembantu/alat.dart`

| Fungsi/Widget | Fungsi |
| --- | --- |
| `keInt(dynamic)` | amankan konversi int |
| `rupiah(int)` | `150000` → `Rp 150.000` (tanpa locale) |
| `formatTanggal(DateTime)` | → `yyyy-MM-dd` |
| `formatJam(TimeOfDay)` | → `HH:mm` (padding nol) |
| `warnaStatus(status)` | `selesai` hijau, `dibatalkan` merah, lainnya biru |
| `chipStatus(status)` | chip warna status |
| `konfirmasiHapus(context)` | dialog konfirmasi, hasil `bool` |
| `tampilPesan(context, teks)` | snackbar satu baris |
| `TombolLebar` | tombol selebar layar tinggi 48 |
| `tampilanGagal(ulang)` | layar gagal muat + tombol Coba Lagi |
| `barisDetail(label, nilai)` | baris label kecil + nilai besar (halaman detail) |

### `pembantu/tema.dart`

Empat konstanta warna di paling atas — cukup ubah ini untuk mengganti seluruh
tema:

| Konstanta | Nilai | Dipakai untuk |
| --- | --- | --- |
| `warnaUtama` | `0xFF2E7D32` hijau tua | tombol, teks aksen, FAB |
| `warnaHeader` | `0xFF1FA64F` hijau cerah | AppBar |
| `warnaAksen` | `0xFFDFF5E3` mint | ikon/avatar di atas hijau |
| `warnaLatar` | `0xFFF1FAF3` | latar scaffold |

`buatTema()` mengatur Material 3, radius 12–16, input filled putih, dan
`ElevatedButton` hijau.

### `pembantu/info_pengguna.dart`

`simpan(token, username)`, `ambilToken()`, `ambilUsername()`, `hapus()`.

---

## 8. Development

### 8.1 Persiapan

```bash
flutter pub get
flutter run            # device/emulator
```

Login: `admin` / `admin`. Tidak butuh internet.

### 8.2 Perintah verifikasi (jalankan sebelum commit)

```bash
flutter analyze        # lint/type check
flutter test           # seluruh test
```

Saat ini `flutter analyze` hanya menampilkan warning lama
`deprecated_member_use` pada `DropdownButtonFormField.value` di 4 form
(`form_booking.dart` ×3, `form_lapangan.dart`) — itu warning Flutter versi
baru, bukan error.

### 8.3 Test yang tersedia

| File | Cakupan |
| --- | --- |
| `test/widget_test.dart` | layar `Masuk` tampil |
| `test/layanan_lokal_test.dart` | CRUD lapangan, pelanggan, booking (tambah → baca → ubah → hapus) + `ambil()` id tak ada melempar `FormatException` |
| `test/info_pengguna_test.dart` | logout menghapus sesi, data CRUD lokal tetap ada |

Test memakai `SharedPreferences.setMockInitialValues({})` di `setUp()`, jadi
tidak menyentuh penyimpanan asli.

### 8.4 Konvensi kode

- Bahasa Indonesia untuk nama file, kelas, fungsi, komentar, dan teks UI.
- Penamaan: file `snake_case.dart`, kelas `PascalCase`, variabel/fungsi
  `camelCase`, konstanta `camelCase` (`warnaUtama`).
- Akhiran arti: `Layanan*` = akses data, `Halaman*` = daftar, `Detail*` =
  rincian, `Form*` = tambah/ubah, `*_item.dart` = kartu baris.
- Satu file satu kelas utama, mengikuti nama file.
- Semua teks UI `const` bila memungkinkan; widget lintas halaman dipindah ke
  `komponen/`, helper murni ke `pembantu/alat.dart`.
- Jangan pernah panggil `SharedPreferences` dari `tampilan/` — selalu lewat
  `layanan/`.

### 8.5 Menambah tabel baru

Contoh: `lapangan` → `turnamen`.

1. Buat `model/turnamen.dart` dengan field JSON, `fromJson`, `toJson`
   (tanpa `id`), default aman.
2. Buat `layanan/layanan_turnamen.dart` berisi 5 metode `daftar`, `ambil`,
   `tambah`, `ubah`, `hapus` yang memakai `PenyimpananLokal('turnamen')`.
3. Buat `tampilan/turnamen/halaman_*.dart`, `detail_*.dart`, `form_*.dart`;
   pakai `tampilanGagal`, `barisDetail`, `TombolLebar`, pola
   `pop(context, hasil)`.
4. Buat `komponen/turnamen_item.dart` bila perlu kartu baris.
5. Tambahkan pintasan di `beranda.dart` dan menu di `menu_samping.dart`.
6. Tambahkan test CRUD di `test/layanan_lokal_test.dart`.

### 8.6 Menambah field baru / mengubah penyimpanan

**Field baru:**

1. Tambahkan field di kelas model + masukkan ke `fromJson` (dengan default
   aman) dan `toJson`.
2. Tambahkan widget input di `form_*.dart` + validator.
3. Tambahkan baris `barisDetail(...)` di `detail_*.dart` bila perlu ditampilkan.
4. Tambahkan asersi field di test lokal.
5. Data lama yang belum punya field ini tetap terbaca karena `fromJson` memberi
   default.

**Ganti media penyimpanan (mis. ke SQLite):** tulis ulang
`pembantu/penyimpanan_lokal.dart` dengan API yang sama
(`daftar/ambil/tambah/ubah/hapus`) — `layanan/` dan seluruh UI tidak berubah.

**Reset seluruh data lokal** (mis. untuk demo):

```dart
final pref = await SharedPreferences.getInstance();
await pref.remove('lokal_lapangan');
await pref.remove('lokal_pelanggan');
await pref.remove('lokal_booking');
```

### 8.7 Catatan logout

`InfoPengguna().hapus()` (dipakai tombol **Keluar**) hanya menghapus kunci
`token` dan `username`. Data CRUD lokal (`lokal_lapangan`, `lokal_pelanggan`,
`lokal_booking`) ikut terhapus hanya bila di-uninstall atau kamu memanggil
`pref.clear()` sendiri.

### 8.8 Ganti warna tema

Buka `lib/pembantu/tema.dart`, ubah 4 konstanta di paling atas (tabel bagian 7).

### 8.9 Build

```bash
flutter build apk --release
```

Aplikasi tidak memakai jaringan, jadi tidak ada permission internet yang
diperlukan. Nama tampilan aplikasi ada di atribut `android:label` manifest
(saat ini `flutter_application_1`; ganti jadi `PadelKu` bila perlu).

---

## 9. Troubleshooting

| Gejala | Penyebab | Solusi |
| --- | --- | --- |
| Data hilang setelah logout | — | logout hanya menghapus sesi, data lokal aman (bagian 8.7) |
| Dropdown "The provided value is not contained in the list" | id lapangan/pelanggan sudah dihapus | sudah ditangani di `FormBooking._muatPilihan()` |
| Tampilan gagal muat / tombol "Coba Lagi" | jarang terjadi pada penyimpanan lokal; bisa dari prefs terkorupsi | reset data (bagian 8.6) |
| `!` di ringkasan beranda | salah satu `daftar()` melempar error | tarik layar ke bawah untuk reload |
| Form tidak bisa simpan | validasi form gagal | baca pesan merah di bawah field |
| Warning `value` deprecated pada form | Flutter versi baru | hanya warning; ganti `value:` jadi `initialValue:` bila ingin bersih |
| Data tertinggal setelah uninstall/reinstall | `shared_preferences` ikut terhapus | normal; data lokal menempel pada instalasi aplikasi |

---

## 10. Catatan Modul

- Login dummy: `admin` / `admin` (bukan autentikasi sungguhan, token hanya
  penanda "sudah login").
- Seluruh CRUD disimpan lokal; tidak ada koneksi internet sama sekali.
- Logika booking (bentrok jadwal, kapasitas lapangan) belum divalidasi —
  `total_bayar` hanya `harga_per_jam × durasi`.
- Peringatan `value is deprecated` pada `DropdownButtonFormField` hanya
  warning, aplikasi tetap jalan.
