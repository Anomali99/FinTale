import '../models/term_model.dart';

class SettingsDict {
  static const TermModel security = TermModel(
    normal: 'Security & Privacy',
    rpg: 'Security & Stealth',
  );

  static const TermModel appSettings = TermModel(
    normal: 'App Settings',
    rpg: 'Game Preferences',
  );

  static const TermModel data = TermModel(
    normal: 'Data & Cloud',
    rpg: 'Magic Archives',
  );

  static const TermModel balanceDec = TermModel(
    normal: 'By default hide nominal',
    rpg: 'By default hide mana',
  );
}
