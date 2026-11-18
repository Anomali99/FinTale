// Template notifikasi CONTOH dengan data FIKTIF.
// ⚠️ CONTOH, BELUM DIVERIFIKASI — format notifikasi ini TIDAK mencerminkan
// format asli dari bank atau e-wallet mana pun. Hanya untuk pengujian logika mesin template.

import 'notification_template.dart';

/// Semua template contoh. Tambahkan template nyata (setelah diverifikasi) di sini.
class ExampleNotificationTemplates {
  ExampleNotificationTemplates._();

  static List<NotificationTemplate> get all => [
    _fiktifBankA,
    _fiktifDompetB,
  ];

  // ---------------------------------------------------------------------------
  // Template 1: Bank Fiktif A
  // ⚠️ CONTOH, BELUM DIVERIFIKASI — data sepenuhnya fiktif.
  // Format notifikasi asli tidak diketahui dan tidak digunakan sebagai referensi.
  // ---------------------------------------------------------------------------
  static final _fiktifBankA = NotificationTemplate(
    name: 'Bank Fiktif A (CONTOH, BELUM DIVERIFIKASI)',
    packageName: 'com.example.bankfiktiif_a',
    transactionPatterns: [
      RegExp(r'\b(berhasil|pembayaran|transaksi|debit|kredit)\b', caseSensitive: false),
    ],
    promoExclusionPatterns: [
      RegExp(r'\b(promo|diskon|cashback|voucher|penawaran|gratis)\b', caseSensitive: false),
    ],
    extractionRules: [
      ExtractionRule(
        field: 'amount',
        // Pola fiktif: "Rp 50.000" atau "IDR 50000"
        pattern: RegExp(r'(?:Rp\.?\s*|IDR\s*)([\d.,]+)', caseSensitive: false),
      ),
      ExtractionRule(
        field: 'direction',
        // Pola fiktif: kata "masuk"/"diterima" vs "keluar"/"dikirim"
        pattern: RegExp(r'\b(masuk|diterima|keluar|dikirim|pembayaran)\b', caseSensitive: false),
      ),
      ExtractionRule(
        field: 'merchant',
        // Pola fiktif: "ke: Nama Toko" atau "dari: Nama Pengirim"
        pattern: RegExp(r'(?:ke|dari):\s*([A-Za-z0-9 ]+)', caseSensitive: false),
      ),
    ],
  );

  // ---------------------------------------------------------------------------
  // Template 2: Dompet Digital Fiktif B
  // ⚠️ CONTOH, BELUM DIVERIFIKASI — data sepenuhnya fiktif.
  // Format notifikasi asli tidak diketahui dan tidak digunakan sebagai referensi.
  // ---------------------------------------------------------------------------
  static final _fiktifDompetB = NotificationTemplate(
    name: 'Dompet Fiktif B (CONTOH, BELUM DIVERIFIKASI)',
    packageName: 'com.example.dompetfiktif_b',
    transactionPatterns: [
      RegExp(r'\b(top.?up|kirim|bayar|transfer|top up berhasil)\b', caseSensitive: false),
    ],
    promoExclusionPatterns: [
      RegExp(r'\b(poin|reward|hadiah|lucky|undian|promo)\b', caseSensitive: false),
    ],
    extractionRules: [
      ExtractionRule(
        field: 'amount',
        // Pola fiktif: "50000 telah"
        pattern: RegExp(r'([\d.,]+)\s*(?:telah|berhasil)', caseSensitive: false),
      ),
      ExtractionRule(
        field: 'direction',
        pattern: RegExp(r'\b(top.?up|diterima|kirim|bayar)\b', caseSensitive: false),
      ),
      ExtractionRule(
        field: 'merchant',
        // Pola fiktif: "kepada Nama Toko"
        pattern: RegExp(r'kepada\s+([A-Za-z0-9 ]+)', caseSensitive: false),
      ),
    ],
  );
}
