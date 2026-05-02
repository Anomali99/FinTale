import '../models/term_model.dart';

class SettingsDict {
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

  static const TermModel balanceDec = TermModel(
    normal: 'Sembunyikan nominal otomatis',
    rpg: 'Sembunyikan HP otomatis',
  );
}
