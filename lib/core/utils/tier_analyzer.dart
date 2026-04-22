import 'package:flutter/material.dart';

import '../../../../models/bill_model.dart';

enum BillTier {
  sss(rank: 'SSS-Rank', color: Colors.deepPurple, title: 'Mythical Quest'),
  ss(rank: 'SS-Rank', color: Colors.purpleAccent, title: 'Legendary Quest'),
  s(rank: 'S-Rank', color: Colors.redAccent, title: 'Epic Quest'),
  a(rank: 'A-Rank', color: Colors.orange, title: 'Hard Quest'),
  b(rank: 'B-Rank', color: Colors.amber, title: 'Adept Quest'),
  c(rank: 'C-Rank', color: Colors.yellow, title: 'Normal Quest'),
  d(rank: 'D-Rank', color: Colors.lightBlue, title: 'Easy Quest'),
  e(rank: 'E-Rank', color: Colors.lightGreen, title: 'Novice Quest'),
  f(rank: 'F-Rank', color: Colors.grey, title: 'Tutorial Quest');

  final String rank;
  final Color color;
  final String title;

  const BillTier({
    required this.rank,
    required this.color,
    required this.title,
  });
}

class TierAnalyzer {
  static int calculateDebtLevel(BigInt amount) {
    final BigInt levelBase = BigInt.from(100000);
    int level = (amount ~/ levelBase).toInt();
    return level < 1 ? 1 : level;
  }

  static BillTier calculateBillTier(BigInt amount, TimeType type) {
    int score = 0;

    if (amount >= BigInt.from(10000000)) {
      score += 50;
    } else if (amount >= BigInt.from(5000000)) {
      score += 40;
    } else if (amount >= BigInt.from(1000000)) {
      score += 30;
    } else if (amount >= BigInt.from(500000)) {
      score += 20;
    } else if (amount >= BigInt.from(100000)) {
      score += 10;
    } else {
      score += 5;
    }

    switch (type) {
      case TimeType.daily:
        score += 50;
        break;
      case TimeType.weekly:
        score += 35;
        break;
      case TimeType.monthly:
        score += 20;
        break;
      case TimeType.annual:
        score += 5;
        break;
    }

    if (score >= 95) return BillTier.sss;
    if (score >= 85) return BillTier.ss;
    if (score >= 70) return BillTier.s;
    if (score >= 60) return BillTier.a;
    if (score >= 50) return BillTier.b;
    if (score >= 40) return BillTier.c;
    if (score >= 30) return BillTier.d;
    if (score >= 20) return BillTier.e;
    return BillTier.f;
  }
}
