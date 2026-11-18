// Tes unit validasi respons TransactionDraft dari server.
// Memverifikasi bahwa wallet_id, category_id, amount, dan tanggal divalidasi dengan benar.

import 'package:flutter_test/flutter_test.dart';
import 'package:fintale/remote/models/transaction_draft.dart';

void main() {
  final validWalletIds = {1, 2, 3};
  final validCategoryIds = {'food', 'salary', 'transport'};

  Map<String, dynamic> baseJson() => {
    'type': 'expense',
    'amount': 50000,
    'currency': 'IDR',
    'occurred_at': '2026-11-18T10:30:00+07:00',
    'merchant': 'Warung Fiktif',
    'note': null,
    'wallet_id': 1,
    'category_id': 'food',
    'confidence': 0.9,
  };

  group('TransactionDraft.fromJson — kasus valid', () {
    test('berhasil parse JSON yang benar', () {
      final draft = TransactionDraft.fromJson(
        baseJson(),
        validWalletIds: validWalletIds,
        validCategoryIds: validCategoryIds,
      );
      expect(draft.type, 'expense');
      expect(draft.amount, 50000);
      expect(draft.walletId, 1);
      expect(draft.categoryId, 'food');
      expect(draft.confidence, closeTo(0.9, 0.001));
    });

    test('wallet_id null diterima', () {
      final json = baseJson()..['wallet_id'] = null;
      final draft = TransactionDraft.fromJson(
        json,
        validWalletIds: validWalletIds,
        validCategoryIds: validCategoryIds,
      );
      expect(draft.walletId, isNull);
    });

    test('category_id null diterima', () {
      final json = baseJson()..['category_id'] = null;
      final draft = TransactionDraft.fromJson(
        json,
        validWalletIds: validWalletIds,
        validCategoryIds: validCategoryIds,
      );
      expect(draft.categoryId, isNull);
    });

    test('type income diterima', () {
      final json = baseJson()
        ..['type'] = 'income'
        ..['category_id'] = 'salary';
      final draft = TransactionDraft.fromJson(
        json,
        validWalletIds: validWalletIds,
        validCategoryIds: validCategoryIds,
      );
      expect(draft.type, 'income');
    });
  });

  group('TransactionDraft.fromJson — kasus tidak valid', () {
    test('FormatException jika amount nol', () {
      final json = baseJson()..['amount'] = 0;
      expect(
        () => TransactionDraft.fromJson(
          json,
          validWalletIds: validWalletIds,
          validCategoryIds: validCategoryIds,
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('FormatException jika amount negatif', () {
      final json = baseJson()..['amount'] = -1000;
      expect(
        () => TransactionDraft.fromJson(
          json,
          validWalletIds: validWalletIds,
          validCategoryIds: validCategoryIds,
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('FormatException jika wallet_id tidak ada di daftar', () {
      final json = baseJson()..['wallet_id'] = 99;
      expect(
        () => TransactionDraft.fromJson(
          json,
          validWalletIds: validWalletIds,
          validCategoryIds: validCategoryIds,
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('FormatException jika category_id tidak ada di daftar', () {
      final json = baseJson()..['category_id'] = 'tidak_ada';
      expect(
        () => TransactionDraft.fromJson(
          json,
          validWalletIds: validWalletIds,
          validCategoryIds: validCategoryIds,
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('FormatException jika occurred_at bukan ISO8601 valid', () {
      final json = baseJson()..['occurred_at'] = 'bukan-tanggal';
      expect(
        () => TransactionDraft.fromJson(
          json,
          validWalletIds: validWalletIds,
          validCategoryIds: validCategoryIds,
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('FormatException jika type adalah transfer', () {
      final json = baseJson()..['type'] = 'transfer';
      expect(
        () => TransactionDraft.fromJson(
          json,
          validWalletIds: validWalletIds,
          validCategoryIds: validCategoryIds,
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
