class TermModel {
  final String normal;
  final String rpg;

  const TermModel({required this.normal, required this.rpg});

  String get(bool isRpgMode) => isRpgMode ? rpg : normal;
}
