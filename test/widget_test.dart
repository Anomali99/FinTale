import 'package:decimal/decimal.dart';
import 'package:fintale/core/constants/gamification_dict.dart';
import 'package:fintale/core/utils/enum_types.dart';
import 'package:fintale/core/utils/hash_helper.dart';
import 'package:fintale/core/utils/leveling_extension.dart';
import 'package:fintale/core/utils/number_utils.dart';
import 'package:fintale/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Skill & Allocation Unit Tests', () {
    test('AllocationMap includes emergencySavings and matches emergency sector total', () {
      final allocLv1 = AllocationMap.getAllocationByLevel(1);
      expect(allocLv1[SectorType.emergency], 20.0);
      expect(allocLv1[SubSectorType.emergencySavings], 10.0);
      expect(allocLv1[SubSectorType.lowRisk], 10.0);

      final limitsLv1 = AllocationMap.getAllocationLimitByLevel(1);
      expect(limitsLv1[SectorType.emergency], 3.0);
      expect(limitsLv1[SubSectorType.emergencySavings], 2.0);
      expect(limitsLv1[SubSectorType.lowRisk], 2.0);
    });

    test('emergencySavings has correct gamification data and null risk', () {
      final skill = GamificationDict.getSkillByEnum(SubSectorType.emergencySavings);
      expect(skill.terminology.normal, 'Tabungan Darurat');
      expect(skill.terminology.rpg, 'Kantong Cadangan');
      expect(SubSectorType.emergencySavings.getRisk(), isNull);
    });
  });

  group('NumberUtils Unit Tests', () {
    test('parseToDecimal handles Indonesian currency formatting', () {
      expect(NumberUtils.parseToDecimal('Rp 50.000'), Decimal.parse('50000'));
      expect(NumberUtils.parseToDecimal('1.500.000,50'), Decimal.parse('1500000.50'));
      expect(NumberUtils.parseToDecimal(''), Decimal.zero);
    });

    test('toIdr formats decimals correctly', () {
      final formatted = NumberUtils.toIdr(Decimal.parse('50000'));
      expect(formatted.contains('50.000'), isTrue);
    });

    test('calculatePercentage handles division and zero total', () {
      expect(NumberUtils.calculatePercentage(50, 100), 50.0);
      expect(NumberUtils.calculatePercentage(10, 0), 0.0);
    });
  });

  group('HashHelper Unit Tests', () {
    test('hashPin produces salted hash and verifyPin succeeds', () {
      const pin = '123456';
      final hashed = HashHelper.hashPin(pin);

      expect(hashed.contains(':'), isTrue);
      expect(HashHelper.verifyPin(pin, hashed), isTrue);
      expect(HashHelper.verifyPin('654321', hashed), isFalse);
    });

    test('verifyPin supports legacy unsalted SHA-256 for backward compatibility', () {
      // sha256('123456') = 8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92
      const legacyHash = '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92';
      expect(HashHelper.verifyPin('123456', legacyHash), isTrue);
      expect(HashHelper.verifyPin('000000', legacyHash), isFalse);
    });
  });

  group('TransactionCategory & Transfer Categories Unit Tests', () {
    test('transferCategories contains expected transfer categories', () {
      final transferCats = TransactionCategory.transferCategories;
      expect(transferCats, contains(TransactionCategory.transfer));
      expect(transferCats, contains(TransactionCategory.pocketTransfer));
      expect(transferCats, contains(TransactionCategory.topUp));
      expect(transferCats, contains(TransactionCategory.emergencyFund));
      expect(transferCats, contains(TransactionCategory.savings));
      expect(transferCats, contains(TransactionCategory.cashWithdrawal));
      expect(transferCats, contains(TransactionCategory.cashDeposit));
    });

    test('incomeCategories and expenseCategories contain all transfer categories', () {
      for (final cat in TransactionCategory.transferCategories) {
        expect(TransactionCategory.incomeCategories, contains(cat));
        expect(TransactionCategory.expenseCategories, contains(cat));
        expect(TransactionCategory.allExpenseCategories, contains(cat));
      }
    });

    test('CategoryDict returns valid definitions for all transfer categories', () {
      for (final cat in TransactionCategory.transferCategories) {
        final dict = cat.categoryDict;
        expect(dict.terminology.normal.isNotEmpty, isTrue);
        expect(dict.terminology.rpg.isNotEmpty, isTrue);
      }
    });
  });

  group('Widget Smoke Tests', () {
    testWidgets('CustomButton renders title and responds to tap', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              color: Colors.blue,
              title: 'Simpan',
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Simpan'), findsOneWidget);
      await tester.tap(find.text('Simpan'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
