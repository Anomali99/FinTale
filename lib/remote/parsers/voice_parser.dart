// Antarmuka dan implementasi remote parser untuk input suara.
// Server hanya menerima TEKS hasil speech_to_text, bukan audio.
// Implementasi lokal dapat ditambahkan nanti dengan mengimplementasikan [VoiceParser].

import '../api/api_client.dart';
import '../models/api_category.dart';
import '../models/api_wallet.dart';
import '../models/transaction_draft.dart';

/// Antarmuka parser suara. Implementasi: [RemoteVoiceParser] (server).
abstract class VoiceParser {
  /// Memparse [text] (hasil speech-to-text on-device) menjadi draf transaksi.
  Future<TransactionDraft> parse({
    required String text,
    required List<ApiWallet> wallets,
    required List<ApiCategory> categories,
  });
}

/// Implementasi remote — mengirim teks ke POST /v1/parse/voice.
class RemoteVoiceParser implements VoiceParser {
  final ApiClient _client;

  const RemoteVoiceParser(this._client);

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

    final response = await _client.post('/v1/parse/voice', body);
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
