// Enum fitur online dan statusnya, sesuai kontrak FinTale versi 2.

/// Fitur yang membutuhkan koneksi server.
enum OnlineFeature {
  /// OCR struk — teks hasil MLKit dikirim ke server untuk diparsing.
  receipt,

  /// Input suara — teks hasil speech_to_text dikirim ke server.
  voice,

  /// Deteksi notifikasi — field hasil ekstraksi template dikirim ke server.
  notification,
}

/// Status ketersediaan fitur online.
enum FeatureStatus {
  /// API_BASE_URL tidak dikonfigurasi atau kosong.
  /// Semua fitur online dinonaktifkan; aplikasi tetap berjalan normal.
  noServer,

  /// Tidak ada koneksi internet atau server tidak terjangkau.
  /// Tidak ada antrean offline.
  offline,

  /// Pengguna belum berlangganan layanan online FinTale.
  notSubscribed,

  /// Fitur siap digunakan.
  available,
}
