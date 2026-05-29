import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/category_model.dart';
import '../models/icon_model.dart';
import '../models/term_model.dart';
import 'app_colors.dart';

class UiDict {
  static const String title = 'Judul';
  static const String name = 'Nama';
  static const String amount = 'Nominal';
  static const String price = 'Harga';
  static const String date = 'Tanggal';
  static const String initialAmount = 'Nominal Awal';
  static const String feeAmount = 'Biaya Admin';

  static const String category = 'Kategori';
  static const String status = 'Status';
  static const String wallet = 'Dompet';
  static const String sourceFunds = 'Sumber Dana';
  static const String sourceFundsShort = 'Dari';
  static const String destinationWallet = 'Dompet Tujuan';
  static const String originWallet = 'Dompet Asal';
  static const String saveTo = 'Disimpan ke';
  static const String saveToShort = 'Ke';

  static const String addNew = 'Tambah Baru';
  static const String addItem = 'Tambah Item Lagi';
  static const String deleteItem = 'Hapus Item';
  static const String saveChanges = 'Simpan Perubahan';
  static const String reset = 'Reset';
  static const String cancel = 'Batal';
  static const String applyFilter = 'Terapkan Filter';

  static const String requiredTitle = 'Judul tidak boleh kosong.';
  static const String requiredName = 'Nama tidak boleh kosong.';
  static const String requiredAmount = 'Nominal tidak boleh kosong.';
  static const String requiredPrice = 'Harga tidak boleh kosong.';
  static const String requiredWallet = 'Silakan pilih sumber dana.';
  static const String requiredWalletDest = 'Silakan pilih dompet tujuan.';
  static const String requiredCategory = 'Silakan pilih kategori.';
  static const String requiredFee = 'Biaya admin tidak boleh kosong.';

  static const String feeCheck = 'Apakah ada biaya administrasi?';
  static const String feeCheckDesc =
      'Aktifkan ini jika penghasilan tersebut dikenakan biaya potongan.';
  static const String autoCheck = 'Alokasi Otomatis?';
  static const String autoCheckDesc =
      'Secara otomatis, distribusikan pendapatan ini ke sektor Anda berdasarkan skill Anda.';

  static const String authJourney = 'Perjalanan Anda Menuju Financial Freedom';
  static const String authWelcome = 'Selamat Datang Para Petualang!';
  static const String authSignIn = 'Masuk dengan Google';
  static const String authSetup = 'Menyiapkan profil karakter Anda...';
  static const String authSkip = 'Lewati';
  static const String authDesc =
      'Siap mengalahkan monster hutang dan membangun kerajaan finansial Anda? Mulailah sekarang.';
  static const String authRequired =
      'Autentikasi diperlukan untuk mengubah pengaturan ini.';
  static const String appLock = 'Aplikasi Terkunci';
  static const String openApp = 'Buka Kunci';
  static const String pinInput = 'Masukkan PIN';
  static const String pinWrong = 'PIN yang Anda masukkan salah.';
  static const String confirmPinWorng = 'PIN konfirmasi tidak cocok.';
  static const String forgotPin = 'Lupa PIN?';
  static const String changeAcount = 'Ubah Akun?';

  static const String changePin = 'Ubah PIN Keamanan';
  static const String changePinCancel = 'Pembaruan PIN dibatalkan.';
  static const String changePinSuccess = 'PIN Keamanan berhasil diperbarui!';

  static const String inputOldPin = 'Masukkan PIN Lama';
  static const String inputOldPinSub =
      'Verifikasi identitas Anda untuk melanjutkan';
  static const String createNewPin = 'Buat PIN Baru';
  static const String createNewPinSub =
      'PIN ini akan digunakan untuk mengunci aplikasi';
  static const String confirmNewPin = 'Konfirmasi PIN Baru';
  static const String confirmNewPinSub =
      'Masukkan kembali 6 digit PIN untuk verifikasi';

  static const String biometric = 'Gunakan Sidik Jari / Face ID';
  static const String biometricDesc = 'Buka aplikasi tanpa memasukkan PIN';
  static const String biometricPrompt =
      'Gunakan Sidik Jari atau PIN untuk konfirmasi';
  static const String biometricFailed = 'Gagal memverifikasi biometrik.';

  static const String settings = 'Pengaturan';
  static const String profile = 'Profil';
  static const String information = 'Panduan & Informasi';
  static const String setSignOut = 'Keluar';
  static const String setSync = 'Sinkronkan ke Cloud';
  static const String setNotification = 'Notifikasi';
  static const String setTheme = 'Tema';
  static const String setRpg = 'Gamification Mode';
  static const String setRpgDesc = 'Gunakan istilah ala game.';
  static const String setHideBalance = 'Sembunyikan Nominal';
  static const String setAppLock = 'Kunci App';
  static const String setLockDesc = 'Kunci aplikasi dengan PIN/Biometrik.';
  static const String setExport = 'Export Data (Json)';
  static const String setImport = 'Import Data';
  static const String setDataReset = 'Reset Data';
  static const String setDataResetBtn = 'Ya, Reset';
  static const String setImportWarning = 'Peringatan Migrasi Data!';
  static const String setImportBtn = 'Ya, Timpa Data';
  static const String setDataResetDesc =
      'Tindakan ini akan menghapus seluruh data dan mengulang progress Anda dari awal. Anda yakin ingin melakukan reset?';
  static const String setImportDesc =
      'Melakukan import akan menghapus seluruh data Anda saat ini dan menimpanya dengan data dari file JSON. Lanjutkan?';
  static const String setNotificationsFiled =
      'Izin notifikasi ditolak oleh sistem.';

  static const String successGenerateDraft = 'Berhasil membuat draf.';
  static const String failedGenerateDraft =
      'Gagal membuat draf karena sudah ada.';
  static const String setSuccessExport = 'Berhasil mengexport data.';
  static const String setFailedExport = 'Gagal mengexport data!';
  static const String setSuccessImport = 'Berhasil mengimport data.';
  static const String setFailedImport = 'Gagal mengimport data!';
  static const String transactionMethode = 'Metode transaksi';
  static const String transactionType = 'Tipe transaksi';
  static const String transactionFilter = 'Filter Transaksi';
  static const String setDate = 'Pilih tanggal awal dan akhir';
  static const String rangeDate = 'Rentang Tanggal';
  static const String noDate = 'Belum dijadwalkan';
  static const String onDay = 'Hari ke-';

  static const TermModel unallocated = TermModel(
    normal: 'Belum Dialokasikan',
    rpg: 'Mana Menganggur',
  );

  static const TermModel setSecurityGroup = TermModel(
    normal: 'Keamanan & Privasi',
    rpg: 'Keamanan & Stealth',
  );
  static const TermModel setAppGroup = TermModel(
    normal: 'Pengaturan Aplikasi',
    rpg: 'Pengaturan Game',
  );
  static const TermModel setDataGroup = TermModel(
    normal: 'Data & Cloud',
    rpg: 'Arsip Sihir',
  );

  static const TermModel setBalanceDesc = TermModel(
    normal: 'Sembunyikan nominal otomatis.',
    rpg: 'Sembunyikan HP otomatis.',
  );

  static CategoryModel income = CategoryModel(
    terminology: TermModel(normal: 'Pemasukan', rpg: 'Loot'),
    color: AppColors.primary,
    icons: IconModel(
      normal: FontAwesomeIcons.arrowTurnDown,
      rpg: FontAwesomeIcons.sackDollar,
    ),
  );

  static const CategoryModel expense = CategoryModel(
    terminology: TermModel(normal: 'Pengeluaran', rpg: 'Damage Diterima'),
    icons: IconModel(
      normal: FontAwesomeIcons.arrowTrendDown,
      rpg: FontAwesomeIcons.heartCrack,
    ),
  );

  static const CategoryModel transfer = CategoryModel(
    terminology: TermModel(normal: 'Transfer', rpg: 'Distribusi'),
    icons: IconModel(
      normal: FontAwesomeIcons.moneyBillTransfer,
      rpg: FontAwesomeIcons.dolly,
    ),
  );

  static const CategoryModel menuHome = CategoryModel(
    terminology: TermModel(normal: 'Beranda', rpg: 'Markas'),
    icons: IconModel(
      normal: FontAwesomeIcons.house,
      rpg: FontAwesomeIcons.chessRook,
    ),
  );

  static const CategoryModel menuBills = CategoryModel(
    terminology: TermModel(normal: 'Tagihan', rpg: 'Papan Misi'),
    icons: IconModel(
      normal: FontAwesomeIcons.receipt,
      rpg: FontAwesomeIcons.scroll,
    ),
  );

  static const CategoryModel menuInvest = CategoryModel(
    terminology: TermModel(normal: 'Investasi', rpg: 'Armory'),
    icons: IconModel(
      normal: FontAwesomeIcons.chartLine,
      rpg: FontAwesomeIcons.shieldHalved,
    ),
  );

  static const CategoryModel menuHistory = CategoryModel(
    terminology: TermModel(normal: 'Riwayat', rpg: 'Catatan'),
    icons: IconModel(
      normal: FontAwesomeIcons.clockRotateLeft,
      rpg: FontAwesomeIcons.bookJournalWhills,
    ),
  );

  static const CategoryModel menuAnalytics = CategoryModel(
    terminology: TermModel(normal: 'Analitik', rpg: 'Laporan'),
    icons: IconModel(
      normal: FontAwesomeIcons.chartPie,
      rpg: FontAwesomeIcons.eye,
    ),
  );

  static const CategoryModel menuPayDebt = CategoryModel(
    terminology: TermModel(normal: 'Bayar Hutang', rpg: 'Serang Boss'),
    description: 'Catat cicilan hutang',
    icons: IconModel(
      normal: FontAwesomeIcons.buildingColumns,
      rpg: FontAwesomeIcons.khanda,
    ),
  );

  static const CategoryModel menuDailyUse = CategoryModel(
    terminology: TermModel(normal: 'Pengeluaran Harian', rpg: 'Gunakan Mana'),
    description: 'Catat makanan, transportasi, dll.',
    icons: IconModel(
      normal: FontAwesomeIcons.wallet,
      rpg: FontAwesomeIcons.flask,
    ),
  );

  static String getNotifTitle(String title) => 'Quest $title Mendekati!';

  static String getNotifBody(String threshold) =>
      'Quest akan aktif dalam $threshold hari. Persiapkan loot Anda!';

  static String getSaveNotif(String name, {bool isSuccess = false}) =>
      '$name ${isSuccess ? 'berhasil' : 'gagal'} disimpan';

  static String getEmptyDesc(String item, {bool isRpg = false}) =>
      isRpg ? 'Tidak ada jejak $item ditemukan.' : 'Tidak ada data $item.';

  static String getEdit(String item) => 'Edit $item';
  static String getTotal(String item) => 'Total $item';
  static String getNominal(String item) => 'Nominal $item';
}
