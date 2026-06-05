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

### 2. Konfigurasi Google Cloud & Lingkungan (.env)

Agar fitur _Cloud Sync_ (Google Drive) dapat berjalan, Anda wajib mendaftarkan SHA-1 dan mengatur kredensial di Google Cloud Console.

#### A. Dapatkan SHA-1 Fingerprint

Jalankan perintah ini di terminal untuk melihat daftar SHA-1 dari Keystore Anda (baik mode Debug maupun Release):

```bash
cd android
./gradlew signingReport
cd ..
```

#### B. Pengaturan Google Cloud Console

1. Buka [Google Cloud Console](https://console.cloud.google.com/) dan buat/pilih proyek Anda.

2. Pergi ke menu **Library**, cari **Google Drive API**, lalu klik **Enable**.

3. Pergi ke menu **OAuth consent screen**. Jika status aplikasi Anda masih _Testing_, pastikan Anda menambahkan alamat email Google Drive Anda sendiri ke dalam daftar **Test users**.

4. Pergi ke menu **Credentials** > **Create Credentials** > **OAuth client ID**.

5. **Buat Kredensial Android:** Pilih _Application type: Android_. Masukkan _Package Name_ (`id.my.anomali99.fintale`) dan masukkan **SHA-1** yang didapat dari langkah A. _(Buat kredensial ini dua kali jika Anda memiliki SHA-1 Debug dan SHA-1 Release)_.

6. **Buat Kredensial Web (Untuk file .env):** Buat kredensial baru dengan tipe _Application type: Web application_. Salin _Client ID_ yang dihasilkan.

#### C. Buat File `.env`

Buat file bernama `.env` di root directory proyek, dan tempelkan Client ID dari tipe Web application tadi ke dalamnya:

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

1. **Buat Keystore:** Buat _Keystore_ Anda sendiri menggunakan Java Keytool:

```bash
keytool -genkey -v -keystore android/app/fintale.jks -keyalg RSA -keysize 2048 -validity 10000 -alias fintale
```

2. **Konfigurasi Kredensial Lokal:** Buat file `android/key.properties` dan masukkan kredensial Keystore Anda:

```properties
storePassword=password_keystore_anda
keyPassword=password_alias_anda
keyAlias=fintale
storeFile=fintale.jks
```

3. **Ambil SHA-1 Release (Wajib untuk Cloud Sync):** Jalankan perintah ini untuk mengekstrak sidik jari SHA-1 dari file `fintale.jks` yang baru saja Anda buat:

```bash
keytool -list -v -keystore android/app/fintale.jks -alias fintale
```

_Salin kode **SHA-1** yang muncul di terminal._

4. Daftarkan ke Google Cloud Console:

- Buka [Google Cloud Console](https://console.cloud.google.com/) dan pilih proyek Anda sebelumnya.

- Buka menu **Credentials** > **+ CREATE CREDENTIALS** > **OAuth client ID**.

- Pilih **Application type: Android**.

- Masukkan _Package Name_ (`id.my.anomali99.fintale`) dan tempelkan kode **SHA-1 Release** yang didapat dari langkah nomor 3.

- Klik **Create** dan tunggu proses propagasi Google sekitar 5 menit.

5. Lakukan Build APK:

```bash
flutter build apk --release
```

atau

```bash
flutter build apk --split-per-abi
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
