// Orkestrasi input suara: speech_to_text on-device → teks → RemoteVoiceParser.
// Audio TIDAK dikirim ke server; hanya teks hasil pengenalan suara.
// Locale: id_ID (Bahasa Indonesia).
// Hasil adalah TransactionDraft yang harus ditinjau pengguna — tidak disimpan otomatis.
// JANGAN log teks hasil pengenalan suara.

import 'dart:async';

import 'package:speech_to_text/speech_to_text.dart';

import '../../models/api_category.dart';
import '../../models/api_wallet.dart';
import '../../models/transaction_draft.dart';
import '../../parsers/voice_parser.dart';

class VoiceInputService {
  final VoiceParser _parser;
  final SpeechToText _speech = SpeechToText();

  bool _isListening = false;

  VoiceInputService({required VoiceParser parser}) : _parser = parser;

  bool get isListening => _isListening;

  /// Menginisialisasi mesin speech-to-text.
  /// Mengembalikan false jika perangkat tidak mendukung atau izin ditolak.
  Future<bool> initialize() async {
    return await _speech.initialize(
      onError: (_) {}, // Error tidak dicatat — JANGAN log detail
    );
  }

  /// Merekam suara dan mengirim teks hasilnya ke server.
  /// Memanggil [onStatusChange] saat status berubah (listening/done).
  /// Melempar exception jika server mengembalikan error.
  Future<TransactionDraft> listen({
    required List<ApiWallet> wallets,
    required List<ApiCategory> categories,
    void Function(bool isListening)? onStatusChange,
  }) async {
    final available = await initialize();
    if (!available) {
      throw StateError('Speech-to-text tidak tersedia di perangkat ini');
    }

    final completer = Completer<String>();
    _isListening = true;
    onStatusChange?.call(true);

    await _speech.listen(
      localeId: 'id_ID',
      onResult: (result) {
        if (result.finalResult && !completer.isCompleted) {
          completer.complete(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
    );

    // Tunggu hasil akhir
    final text = await completer.future;
    _isListening = false;
    onStatusChange?.call(false);

    if (text.trim().isEmpty) {
      throw StateError('Tidak ada suara yang terdeteksi');
    }

    // Teks tidak dicatat di log
    return _parser.parse(text: text, wallets: wallets, categories: categories);
  }

  Future<void> stop() async {
    await _speech.stop();
    _isListening = false;
  }
}
