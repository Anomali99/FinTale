// Orkestrasi OCR struk: MLKit on-device → teks → RemoteReceiptParser.
// Gambar/foto TIDAK dikirim ke server; hanya teks hasil OCR.
// Hasil adalah TransactionDraft yang harus ditinjau pengguna — tidak disimpan otomatis.
// JANGAN log teks hasil OCR.

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../models/api_category.dart';
import '../../models/api_wallet.dart';
import '../../models/transaction_draft.dart';
import '../../parsers/receipt_parser.dart';

class ReceiptScanService {
  final ReceiptParser _parser;
  final TextRecognizer _recognizer;

  ReceiptScanService({required ReceiptParser parser})
    : _parser = parser,
      _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Memproses [imagePath] dengan MLKit lalu mengirim teks ke server.
  /// Melempar exception jika OCR gagal atau server mengembalikan error.
  Future<TransactionDraft> scanFromFile({
    required String imagePath,
    required List<ApiWallet> wallets,
    required List<ApiCategory> categories,
  }) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizedText = await _recognizer.processImage(inputImage);
    final text = recognizedText.text;

    // Teks tidak dicatat di log
    return _parser.parse(text: text, wallets: wallets, categories: categories);
  }

  Future<void> dispose() async {
    await _recognizer.close();
  }
}
