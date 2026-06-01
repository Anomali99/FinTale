# FinTale 🪙

FinTale adalah aplikasi pencatat keuangan pribadi berbasis _offline-first_ yang dirancang untuk membuat manajemen keuangan menjadi lebih terstruktur dan menyenangkan. Dengan menggabungkan prinsip _budgeting_ cerdas dan elemen gamifikasi bergaya RPG, FinTale membantu pengguna membangun kebiasaan finansial yang sehat secara konsisten tanpa mengorbankan privasi data.

## 📥 Download Aplikasi (Untuk Pengguna Umum)

Jika Anda hanya ingin langsung menggunakan aplikasi tanpa perlu melakukan _build_ dari kode sumber, silakan unduh versi terbarunya di sini:

👉 **[Download APK FinTale (Versi Terbaru) di GitHub Releases](https://github.com/Anomali99/FinTale/releases/latest)**

_(Cukup unduh file berekstensi `.apk` dan instal di perangkat Android Anda)._

---

## ✨ Fitur Utama

- 🎮 **Gamifikasi Finansial (RPG Mode):** Ubah aktivitas mencatat keuangan menjadi petualangan. Dapatkan _Experience Points_ (XP), naik level, dan raih gelar _(Title)_ dari _Novice Saver_ hingga _Financial Master_ dengan menyelesaikan misi keuangan rutin.
- 📊 **Smart Allocation & Skill Map:** Sistem alokasi dana dinamis (Biaya Hidup, Bayar Hutang, Dana Darurat, dan Investasi) yang persentase idealnya akan terbuka dan menyesuaikan seiring dengan naiknya level pengguna.
- 💸 **Manajemen Anggaran & Penalti:** Pantau _Daily Limit_ (Batas Pengeluaran Harian) secara _real-time_. Kelebihan pengeluaran hari ini (_offset_) akan otomatis dicatat sebagai penalti yang memotong anggaran di hari berikutnya.
- 🗓️ **Quest & Tagihan Rutin:** Catat tagihan bulanan atau cicilan Anda layaknya sebuah _Quest_. Sistem akan memberikan notifikasi pengingat secara otomatis ketika mendekati tenggat waktu (jatuh tempo) agar Anda tidak pernah terkena denda keterlambatan.
- 🍩 **Analitik Visual (Donut Chart):** Pantau arus kas Anda melalui grafik _Donut Chart_ yang intuitif. Laporan pengeluaran umum (biaya hidup) dipisahkan secara cerdas dari alokasi investasi, memberikan Anda gambaran kekayaan dan kebiasaan belanja yang jauh lebih akurat.
- 🔒 **100% Offline-First (Privasi Mutlak):** FinTale **tidak menggunakan API pihak ketiga mana pun** untuk melacak data bank atau pasar keuangan. Seluruh data keuangan disimpan secara lokal di dalam perangkat Anda menggunakan SQLite. Satu-satunya koneksi keluar adalah ke akun Google Drive pribadi Anda saat Anda menekan tombol _Backup_.
- 📈 **Manajemen Investasi Mandiri:** Catat dan pantau portofolio investasi Anda (Risiko Rendah, Menengah, Tinggi) lengkap dengan fitur penarikan modal dan klaim dividen.
  > ⚠️ **Catatan Penting:** Karena ketiadaan API pihak ketiga, pergerakan harga pasar tidak berjalan otomatis. **Pengguna diharapkan memperbarui nilai (_value_) aset investasinya secara manual secara rutin** (misalnya seminggu atau sebulan sekali) agar persentase _profit/loss_ tetap akurat.
- ☁️ **Manual Cloud Sync:** Cadangkan dan pulihkan data JSON Anda dengan aman langsung ke Google Drive pribadi Anda.

## 🛠️ Teknologi yang Digunakan

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **State Management:** Provider
- **Database:** SQLite (Lokal via `sqflite`)
- **Cloud Backup:** Google Sign-In v7 & Google APIs (Drive)

---

## 🚀 Build dari Source (Untuk Developer)

Jika Anda ingin memodifikasi atau berkontribusi pada proyek ini, ikuti langkah-langkah berikut:

### 1. Prasyarat & Kloning

- Pastikan Flutter SDK telah terinstal.
- Kloning repositori ini dan unduh dependensinya:

```bash
git clone https://github.com/Anomali99/FinTale.git
cd FinTale
flutter pub get
```

### 2. Konfigurasi Lingkungan (.env)

Buat file bernama `.env` di root directory proyek, dan tambahkan `Client ID `berjenis Web application dari Google Cloud Console Anda:

```env
# Wajib menggunakan tipe Web Client, bukan Android Client
SERVER_CLIENT_ID=masukkan-web-client-id-anda
```

### 3. Opsi Build & Run

#### A. Mode Debug (Untuk Pengembangan Cepat)

Anda bisa langsung menjalankan aplikasi di emulator atau perangkat fisik untuk pengujian:

```bash
flutter run
```

#### B. Mode Release (Build APK / AppBundle)

Untuk membuat APK yang siap didistribusikan (Production), Anda harus mengatur Keystore Android terlebih dahulu.

1. Buat _Keystore_ Anda sendiri menggunakan Java Keytool:

```bash
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias fintale
```

2. Buat file `android/key.properties` dan masukkan kredensial Keystore Anda:

```properties
storePassword=password_keystore_anda
keyPassword=password_alias_anda
keyAlias=fintale
storeFile=/lokasi/absolut/ke/key.jks
```

3. Lakukan Build APK:

```bash
flutter build apk --release
```

## 📄 Lisensi

**Creative Commons Attribution-NonCommercial 4.0 International (CC BY-NC 4.0)**

Copyright (c) 2026 Anomali99

Proyek ini dilindungi oleh lisensi CC BY-NC 4.0. Anda diizinkan untuk:

- ✅ **Mengunduh dan menggunakan** aplikasi ini untuk keperluan pribadi.
- ✅ **Memodifikasi dan membagikan** ulang kode sumber ini secara gratis.

Dengan syarat mutlak:

- ❌ **NON-KOMERSIAL:** Anda **DILARANG KERAS** menggunakan aplikasi atau kode sumber ini untuk tujuan komersial (seperti menjualnya kembali, menyematkan iklan/AdMob, menjadikannya layanan berbayar, atau memonetisasinya dalam bentuk apa pun).
- 📝 **Atribusi:** Anda harus mencantumkan kredit yang sesuai kepada pembuat asli (Anomali99) jika Anda membagikan ulang kode ini.

Untuk membaca detail hukum lisensi ini, silakan kunjungi:
[https://creativecommons.org/licenses/by-nc/4.0/](https://creativecommons.org/licenses/by-nc/4.0/)
