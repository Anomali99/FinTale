// Draf transaksi dari server — BUKAN model DB.
// Draf tidak pernah disimpan otomatis; pengguna harus meninjau dan mengonfirmasi.
// Pemetaan ke model DB saat simpan:
//   merchant -> TransactionModel.title  (null = pengguna isi manual)
//   note     -> TransactionDetailModel.title (item pertama)
//   currency -> dibuang (selalu IDR)
//   occurred_at ISO8601 -> TransactionModel.dateTimestamp (ms epoch)

class TransactionDraft {
  /// "expense" atau "income". Parser tidak menghasilkan "transfer" atau "debt".
  final String type;

  /// Nominal dalam rupiah, selalu positif. Arah ditentukan oleh [type].
  final int amount;

  /// Selalu "IDR". Hanya metadata tampilan, tidak disimpan ke DB.
  final String currency;

  /// Waktu transaksi (sudah diparsing dari ISO8601).
  final DateTime occurredAt;

  /// Nama merchant/toko. Dipetakan ke TransactionModel.title saat simpan.
  /// Null berarti pengguna harus mengisi judul secara manual.
  final String? merchant;

  /// Catatan tambahan. Dipetakan ke TransactionDetailModel.title (item pertama).
  final String? note;

  /// Id WalletModel di database (integer). Sudah divalidasi ada di daftar yang dikirim, atau null.
  final int? walletId;

  /// Nama enum TransactionCategory. Sudah divalidasi ada di daftar yang dikirim, atau null.
  final String? categoryId;

  /// Kepercayaan server terhadap hasil parsing (0.0–1.0). Hanya untuk tampilan UI.
  final double confidence;

  const TransactionDraft({
    required this.type,
    required this.amount,
    required this.currency,
    required this.occurredAt,
    required this.confidence,
    this.merchant,
    this.note,
    this.walletId,
    this.categoryId,
  });

  /// Memvalidasi isi draft terhadap daftar yang dikirim ke server.
  /// Mengembalikan null jika valid, atau String deskripsi masalah jika tidak valid.
  String? validate({
    required Set<int> validWalletIds,
    required Set<String> validCategoryIds,
  }) {
    if (amount <= 0) return 'amount harus bilangan bulat positif, dapat: $amount';
    if (type != 'expense' && type != 'income') {
      return 'type tidak valid: $type';
    }
    if (walletId != null && !validWalletIds.contains(walletId)) {
      return 'wallet_id tidak ditemukan dalam daftar yang dikirim';
    }
    if (categoryId != null && !validCategoryIds.contains(categoryId)) {
      return 'category_id tidak ditemukan dalam daftar yang dikirim';
    }
    return null;
  }

  /// Memparse JSON dari respons server dan memvalidasi hasilnya.
  /// Melempar [FormatException] jika skema salah atau validasi gagal.
  factory TransactionDraft.fromJson(
    Map<String, dynamic> json, {
    required Set<int> validWalletIds,
    required Set<String> validCategoryIds,
  }) {
    // Validasi field wajib
    final type = json['type'];
    if (type is! String || (type != 'expense' && type != 'income')) {
      throw const FormatException('TransactionDraft: type tidak valid');
    }

    final rawAmount = json['amount'];
    final int amount;
    if (rawAmount is int) {
      amount = rawAmount;
    } else if (rawAmount is double) {
      amount = rawAmount.toInt();
    } else {
      throw const FormatException('TransactionDraft: amount harus integer');
    }
    if (amount <= 0) {
      throw const FormatException('TransactionDraft: amount harus positif');
    }

    final rawDate = json['occurred_at'];
    if (rawDate is! String) {
      throw const FormatException('TransactionDraft: occurred_at harus string ISO8601');
    }
    final DateTime occurredAt;
    try {
      occurredAt = DateTime.parse(rawDate);
    } catch (_) {
      throw const FormatException('TransactionDraft: occurred_at bukan tanggal valid');
    }

    final currency = (json['currency'] as String?) ?? 'IDR';

    final rawWalletId = json['wallet_id'];
    final int? walletId = rawWalletId is int ? rawWalletId : null;

    final rawCategoryId = json['category_id'];
    final String? categoryId = rawCategoryId is String ? rawCategoryId : null;

    final rawConfidence = json['confidence'];
    final double confidence;
    if (rawConfidence is double) {
      confidence = rawConfidence;
    } else if (rawConfidence is int) {
      confidence = rawConfidence.toDouble();
    } else {
      confidence = 0.0;
    }

    final draft = TransactionDraft(
      type: type,
      amount: amount,
      currency: currency,
      occurredAt: occurredAt,
      merchant: json['merchant'] as String?,
      note: json['note'] as String?,
      walletId: walletId,
      categoryId: categoryId,
      confidence: confidence,
    );

    // Validasi referensial
    final error = draft.validate(
      validWalletIds: validWalletIds,
      validCategoryIds: validCategoryIds,
    );
    if (error != null) {
      throw FormatException('TransactionDraft: $error');
    }

    return draft;
  }
}
