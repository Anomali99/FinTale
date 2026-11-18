// Konfigurasi aplikasi — membaca nilai dari .env dengan aman.
// API_BASE_URL kosong atau hanya spasi dianggap null (semua fitur online nonaktif).
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  /// Logika parsing URL — pure function, dapat diuji tanpa dotenv.
  /// Mengembalikan null jika [raw] null, kosong, atau hanya spasi.
  static String? parseBaseUrl(String? raw) {
    final trimmed = raw?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  /// Base URL server FinTale.
  /// Null jika tidak dikonfigurasi, kosong, atau hanya berisi spasi —
  /// dalam kondisi ini seluruh fitur online dinonaktifkan dan aplikasi tetap berjalan normal.
  static String? get apiBaseUrl => parseBaseUrl(dotenv.maybeGet('API_BASE_URL'));
}
