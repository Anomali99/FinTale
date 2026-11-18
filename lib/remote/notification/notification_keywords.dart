// Daftar kata kunci untuk klasifikasi notifikasi transaksi vs promo.
// Data terpisah dari logika — sesuai prinsip kontrak FinTale.
// JANGAN hardcode kata-kata ini di logika inti.

class NotificationKeywords {
  NotificationKeywords._();

  /// Kata kerja yang menunjukkan transaksi keuangan.
  /// Notifikasi harus mengandung SETIDAKNYA SATU kata ini DAN ada nominal.
  static const List<String> transactionVerbs = [
    'berhasil',
    'diterima',
    'dikirim',
    'pembayaran',
    'debit',
    'kredit',
    'top up',
    'topup',
    'transfer',
    'transaksi',
    'bayar',
    'tarik',
    'setor',
    'masuk',
    'keluar',
    'ditagih',
    'cicilan',
  ];

  /// Kata yang menandai promosi/iklan — notifikasi dengan kata ini dibuang.
  static const List<String> promoKeywords = [
    'diskon',
    'cashback',
    'voucher',
    'promo',
    'penawaran',
    'gratis',
    'hadiah',
    'poin',
    'reward',
    'lucky',
    'undian',
    'bonus',
    'cicilan 0%',
    'bunga 0',
    'spesial',
    'terbatas',
  ];
}
