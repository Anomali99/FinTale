import '../models/term_model.dart';

class ProfilDict {
  static const TermModel missions = TermModel(
    normal: 'Daily Missions',
    rpg: 'Guild Tasks',
  );

  static const TermModel stats = TermModel(
    normal: 'Allocation Stats',
    rpg: 'Combat Stats',
  );

  static const TermModel allocationTree = TermModel(
    normal: 'Allocation Tree',
    rpg: 'Skill Tree',
  );
}
