// Tes unit AppConfig.parseBaseUrl — pure function, tidak membutuhkan dotenv.
// Memverifikasi bahwa URL kosong/spasi dianggap null.

import 'package:flutter_test/flutter_test.dart';
import 'package:fintale/remote/config/app_config.dart';

void main() {
  group('AppConfig.parseBaseUrl', () {
    test('null jika input null', () {
      expect(AppConfig.parseBaseUrl(null), isNull);
    });

    test('null jika string kosong', () {
      expect(AppConfig.parseBaseUrl(''), isNull);
    });

    test('null jika hanya spasi', () {
      expect(AppConfig.parseBaseUrl('   '), isNull);
    });

    test('null jika hanya tab', () {
      expect(AppConfig.parseBaseUrl('\t'), isNull);
    });

    test('null jika campuran spasi dan newline', () {
      expect(AppConfig.parseBaseUrl('  \n  '), isNull);
    });

    test('mengembalikan URL yang di-trim jika ada spasi di tepi', () {
      expect(
        AppConfig.parseBaseUrl('  https://api.fintale.app  '),
        'https://api.fintale.app',
      );
    });

    test('mengembalikan URL apa adanya jika tidak ada spasi', () {
      expect(
        AppConfig.parseBaseUrl('https://api.fintale.app'),
        'https://api.fintale.app',
      );
    });
  });
}
