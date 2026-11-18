// Klasifikasi awal notifikasi (transaksi / promo / ambigu) sebelum dikirim ke server.
// Menggunakan kata kunci dari NotificationKeywords — data terpisah dari logika.
// Notifikasi promo dan ambigu dibuang diam-diam tanpa dicatat isinya.

import 'notification_keywords.dart';

enum NotificationClassification {
  /// Mengandung kata kerja transaksi DAN nominal — lanjutkan ke server.
  likelyTransaction,

  /// Mengandung kata promo tanpa kata kerja transaksi — buang.
  promo,

  /// Tidak termasuk kategori manapun secara jelas — buang.
  ambiguous,
}

class NotificationFilter {
  /// Pola angka (nominal) di teks notifikasi.
  static final _amountPattern = RegExp(r'(?:Rp\.?\s*|IDR\s*)?\d[\d.,]{2,}');

  static final _transactionPattern = RegExp(
    '(?:${NotificationKeywords.transactionVerbs.map(RegExp.escape).join('|')})',
    caseSensitive: false,
  );

  static final _promoPattern = RegExp(
    '(?:${NotificationKeywords.promoKeywords.map(RegExp.escape).join('|')})',
    caseSensitive: false,
  );

  /// Mengklasifikasikan notifikasi berdasarkan konten teks.
  /// [text] tidak dicatat di log — hanya diproses, hasilnya classification.
  static NotificationClassification classify(String text) {
    final hasPromo = _promoPattern.hasMatch(text);
    final hasTransaction = _transactionPattern.hasMatch(text);
    final hasAmount = _amountPattern.hasMatch(text);

    // Promo tanpa kata transaksi → buang
    if (hasPromo && !hasTransaction) return NotificationClassification.promo;

    // Kata transaksi + nominal → lanjutkan
    if (hasTransaction && hasAmount) {
      return NotificationClassification.likelyTransaction;
    }

    // Semua kasus lain → ambigu, buang diam-diam
    return NotificationClassification.ambiguous;
  }
}
