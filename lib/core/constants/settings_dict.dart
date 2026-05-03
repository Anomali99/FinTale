import '../models/term_model.dart';

class SettingsDict {
  static const String signOut = 'Keluar';
  static const String sync = 'Sinkronkan ke Cloud';
  static const String notifications = 'Notifikasi';
  static const String theme = 'Tema';
  static const String appLocDesc = 'Kunci aplikasi dengan PIN/Biometrik.';
  static const String rpgDesc = 'Gunakan istilah ala game.';

  static const TermModel security = TermModel(
    normal: 'Keamanan & Privasi',
    rpg: 'Keamanan & Stealth',
  );

  static const TermModel appSettings = TermModel(
    normal: 'Pengaturan Aplikasi',
    rpg: 'Pengaturan Game',
  );

  static const TermModel data = TermModel(
    normal: 'Data & Cloud',
    rpg: 'Arsip Sihir',
  );

  static const TermModel balanceDesc = TermModel(
    normal: 'Sembunyikan nominal otomatis.',
    rpg: 'Sembunyikan HP otomatis.',
  );
}
