// Antarmuka dan implementasi remote parser untuk OCR struk.
// Server hanya menerima TEKS hasil OCR, bukan gambar.
// Implementasi lokal dapat ditambahkan nanti dengan mengimplementasikan [ReceiptParser].

import '../api/api_client.dart';
import '../models/api_category.dart';
import '../models/api_wallet.dart';
import '../models/transaction_draft.dart';

/// Antarmuka parser struk. Implementasi: [RemoteReceiptParser] (server),
/// dan di masa depan bisa ditambahkan implementasi lokal.
abstract class ReceiptParser {
  /// Memparse [text] (hasil OCR on-device) menjadi draf transaksi.
  /// [wallets] dan [categories] digunakan oleh server untuk mapping.
  Future<TransactionDraft> parse({
    required String text,
    required List<ApiWallet> wallets,
    required List<ApiCategory> categories,
  });
}

/// Implementasi remote — mengirim teks ke POST /v1/parse/receipt.
class RemoteReceiptParser implements ReceiptParser {
  final ApiClient _client;

  const RemoteReceiptParser(this._client);

  @override
  Future<TransactionDraft> parse({
    required String text,
    required List<ApiWallet> wallets,
    required List<ApiCategory> categories,
  }) async {
    final body = {
      'text': text,
      'wallets': wallets.map((w) => w.toJson()).toList(),
      'categories': categories.map((c) => c.toJson()).toList(),
    };

    final response = await _client.post('/v1/parse/receipt', body);
    final draftJson = response['draft'] as Map<String, dynamic>?;
    if (draftJson == null) {
      throw const FormatException('Respons server tidak memiliki field "draft"');
    }

    return TransactionDraft.fromJson(
      draftJson,
      validWalletIds: wallets.map((w) => w.id).toSet(),
      validCategoryIds: categories.map((c) => c.id).toSet(),
    );
  }
}
