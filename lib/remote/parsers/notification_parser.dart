// Antarmuka dan implementasi remote parser untuk notifikasi.
// Hanya field hasil ekstraksi template yang dikirim — BUKAN teks mentah notifikasi.
// Implementasi lokal dapat ditambahkan nanti dengan mengimplementasikan [NotificationParser].

import '../api/api_client.dart';
import '../models/api_category.dart';
import '../models/api_wallet.dart';
import '../models/transaction_draft.dart';

/// Hasil parsing notifikasi dari server.
class NotificationParseResult {
  /// True jika server mengonfirmasi ini adalah transaksi.
  final bool isTransaction;

  /// Draf transaksi jika [isTransaction] true. Null jika bukan transaksi.
  final TransactionDraft? draft;

  /// Alasan server menolak (opsional, hanya untuk debugging internal — JANGAN tampilkan ke user).
  final String? reason;

  const NotificationParseResult({
    required this.isTransaction,
    this.draft,
    this.reason,
  });
}

/// Payload ekstraksi notifikasi — hanya field yang sudah diekstrak oleh template.
/// Nomor rekening/kartu sudah dibuang sebelum objek ini dibuat.
class NotificationExtract {
  final String sourceApp;
  final String? direction; // "in" | "out" | null
  final int amount;
  final String? merchant;
  final String? note;
  final DateTime occurredAt;

  const NotificationExtract({
    required this.sourceApp,
    required this.amount,
    required this.occurredAt,
    this.direction,
    this.merchant,
    this.note,
  });
}

/// Antarmuka parser notifikasi. Implementasi: [RemoteNotificationParser] (server).
abstract class NotificationParser {
  /// Mengirim hasil ekstraksi ke server untuk dikonfirmasi dan diparsing lebih lanjut.
  Future<NotificationParseResult> parse({
    required NotificationExtract extract,
    required List<ApiWallet> wallets,
    required List<ApiCategory> categories,
  });
}

/// Implementasi remote — mengirim ekstrak ke POST /v1/parse/notification.
class RemoteNotificationParser implements NotificationParser {
  final ApiClient _client;

  const RemoteNotificationParser(this._client);

  @override
  Future<NotificationParseResult> parse({
    required NotificationExtract extract,
    required List<ApiWallet> wallets,
    required List<ApiCategory> categories,
  }) async {
    final body = {
      'source_app': extract.sourceApp,
      'direction': extract.direction,
      'amount': extract.amount,
      'merchant': extract.merchant,
      'note': extract.note,
      'occurred_at': extract.occurredAt.toIso8601String(),
      'wallets': wallets.map((w) => w.toJson()).toList(),
      'categories': categories.map((c) => c.toJson()).toList(),
    };

    final response = await _client.post('/v1/parse/notification', body);
    final isTransaction = response['is_transaction'] as bool? ?? false;

    if (!isTransaction) {
      return const NotificationParseResult(isTransaction: false);
    }

    final draftJson = response['draft'] as Map<String, dynamic>?;
    if (draftJson == null) {
      return const NotificationParseResult(isTransaction: false);
    }

    final draft = TransactionDraft.fromJson(
      draftJson,
      validWalletIds: wallets.map((w) => w.id).toSet(),
      validCategoryIds: categories.map((c) => c.id).toSet(),
    );

    return NotificationParseResult(isTransaction: true, draft: draft);
  }
}
