// Model template notifikasi — data terpisah dari logika mesin template.
// Template menyimpan pola pencocokan dan regex ekstraksi.
// DILARANG mengarang format notifikasi bank/e-wallet asli.

/// Satu aturan regex ekstraksi dari teks notifikasi.
class ExtractionRule {
  /// Nama field yang diekstrak (amount, direction, merchant, time).
  final String field;

  /// Pattern regex untuk mengekstrak nilai.
  final RegExp pattern;

  /// Indeks capture group yang berisi nilai (default: 1).
  final int groupIndex;

  const ExtractionRule({
    required this.field,
    required this.pattern,
    this.groupIndex = 1,
  });
}

/// Template notifikasi untuk satu aplikasi sumber.
class NotificationTemplate {
  /// Nama template (hanya untuk identifikasi internal).
  final String name;

  /// Package name Android aplikasi sumber.
  final String packageName;

  /// Pola yang HARUS ada agar notifikasi dianggap transaksi.
  /// Setidaknya satu pola harus cocok.
  final List<RegExp> transactionPatterns;

  /// Pola yang jika cocok menyebabkan notifikasi DIABAIKAN (promo, iklan, dsb).
  final List<RegExp> promoExclusionPatterns;

  /// Aturan ekstraksi field dari teks notifikasi.
  final List<ExtractionRule> extractionRules;

  const NotificationTemplate({
    required this.name,
    required this.packageName,
    required this.transactionPatterns,
    required this.promoExclusionPatterns,
    required this.extractionRules,
  });
}
