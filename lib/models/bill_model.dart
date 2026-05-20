import 'package:intl/intl.dart';

import '../core/constants/screen_dict.dart';
import '../core/utils/enum_types.dart';
import '../core/utils/tier_analyzer.dart';
import 'transaction_detail_model.dart';
import 'transaction_model.dart';

class BillModel {
  final int? id;
  final int? debtId;
  final String title;
  final BigInt amount;
  final TimeType type;
  final int? day;
  final int? month;
  final DayName? dayName;
  bool isActive;
  int? nextDueDate;

  BillModel({
    required this.title,
    required this.amount,
    required this.type,

    this.id,
    this.debtId,
    this.day,
    this.month,
    this.dayName,
    this.nextDueDate,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "debt_id": debtId,
      "title": title,
      "amount": amount.toString(),
      "type": type.name,
      "day_name": dayName?.name,
      "day": day,
      "month": month,
      "is_active": isActive ? 1 : 0,
      "next_due_date": nextDueDate,
    };
  }

  factory BillModel.fromMap(Map<String, dynamic> map) {
    return BillModel(
      id: map['id'],
      debtId: map['debt_id'],
      title: map['title'],
      amount: BigInt.parse(map['amount'] ?? '0'),
      type: TimeType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TimeType.annual,
      ),
      dayName: DayName.values.firstWhere(
        (e) => e.name == map['day_name'],
        orElse: () => DayName.sunday,
      ),
      day: map['day'],
      month: map['month'],
      isActive: map['is_active'] == 1,
      nextDueDate: map['next_due_date'],
    );
  }
}

extension BillExtension on BillModel {
  BillTier get tier => TierAnalyzer.calculateBillTier(amount, type);

  void toggleActive(bool value) {
    isActive = value;
  }

  String getScheduleTitle() {
    switch (type) {
      case TimeType.daily:
        return TimeType.daily.value;
      case TimeType.weekly:
        return '${TimeType.weekly.value} (${dayName?.value ?? ''})';
      case TimeType.monthly:
        return '${TimeType.monthly.value} (${day ?? '-'})';
      case TimeType.annual:
        return '${TimeType.annual.value} (${day ?? '-'} ${month ?? '-'})';
    }
  }

  String _getTargetTitle(DateTime targetDate) {
    switch (type) {
      case TimeType.daily:
        return DateFormat('EEEE, dd MMMM yyyy').format(targetDate);
      case TimeType.weekly:
        return DateFormat('dd MMMM yyyy').format(targetDate);
      case TimeType.monthly:
        return DateFormat('MMMM yyyy').format(targetDate);
      case TimeType.annual:
        return DateFormat('yyyy').format(targetDate);
    }
  }

  TransactionModel generateTransaction({required bool isDirectPay}) {
    DateTime now = DateTime.now();
    DateTime targetDate = nextDueDate != null
        ? DateTime.fromMillisecondsSinceEpoch(nextDueDate!)
        : _calculateNextDateFrom(now);

    TransactionModel transaction = TransactionModel(
      type: TransactionType.expense,
      billId: id,
      debtId: debtId,
      title: title,
      amount: amount,
      status: isDirectPay ? StatusType.paid : StatusType.pending,
      dateTimestamp: isDirectPay
          ? now.millisecondsSinceEpoch
          : targetDate.millisecondsSinceEpoch,
      detailTransaction: [
        TransactionDetailModel(
          title:
              '${ScreenDict.billsMaster.normal} (${_getTargetTitle(targetDate)})',
          amount: amount,
          flow: FlowType.expense,
          category: debtId != null
              ? TransactionCategory.debtInstallment
              : TransactionCategory.utilities,
        ),
      ],
    );

    advanceToNextBill();

    return transaction;
  }

  bool isGeneratedForCurrentPeriod() {
    if (nextDueDate == null) return false;

    DateTime now = DateTime.now();
    DateTime currentPeriodTarget = _getCurrentPeriodDueDate(now);

    DateTime nextDate = DateTime.fromMillisecondsSinceEpoch(nextDueDate!);
    DateTime normalizedNextDate = DateTime(
      nextDate.year,
      nextDate.month,
      nextDate.day,
    );

    return normalizedNextDate.isAfter(currentPeriodTarget);
  }

  bool shouldAutoGenerate() {
    if (!isActive || nextDueDate == null) return false;

    DateTime now = DateTime.now();
    DateTime dueDate = DateTime.fromMillisecondsSinceEpoch(nextDueDate!);

    int differenceInDays = dueDate.difference(now).inDays;

    return differenceInDays <= 15 && differenceInDays >= 0;
  }

  static StatusType checkTransactionStatus(
    int dateTimestamp,
    StatusType currentStatus,
  ) {
    if (currentStatus != StatusType.pending) return currentStatus;

    DateTime now = DateTime.now();
    DateTime dueDate = DateTime.fromMillisecondsSinceEpoch(dateTimestamp);

    if (now.isAfter(dueDate)) {
      return StatusType.overdue;
    }

    return currentStatus;
  }

  void skipNextBill() {
    DateTime currentTarget = nextDueDate != null
        ? DateTime.fromMillisecondsSinceEpoch(nextDueDate!)
        : _calculateNextDateFrom(DateTime.now());

    DateTime newlyCalculatedDate = _calculateNextDateFrom(currentTarget);
    nextDueDate = newlyCalculatedDate.millisecondsSinceEpoch;
  }

  void advanceToNextBill() {
    skipNextBill();
  }

  DateTime _getCurrentPeriodDueDate(DateTime now) {
    DateTime baseDate = DateTime(now.year, now.month, now.day);

    switch (type) {
      case TimeType.daily:
        return baseDate;

      case TimeType.weekly:
        int targetWeekday = _getWeekdayFromDayName(dayName ?? DayName.monday);
        int diff = targetWeekday - baseDate.weekday;
        return baseDate.add(Duration(days: diff));

      case TimeType.monthly:
        int targetDay = day ?? 1;
        return _clampDate(baseDate.year, baseDate.month, targetDay);

      case TimeType.annual:
        int targetMonth = month ?? 1;
        int targetDay = day ?? 1;
        return _clampDate(baseDate.year, targetMonth, targetDay);
    }
  }

  DateTime _calculateNextDateFrom(DateTime base) {
    switch (type) {
      case TimeType.daily:
        return base.add(const Duration(days: 1));

      case TimeType.weekly:
        int targetWeekday = _getWeekdayFromDayName(dayName ?? DayName.monday);
        int daysToAdd = (targetWeekday - base.weekday + 7) % 7;
        if (daysToAdd == 0) daysToAdd = 7;
        return base.add(Duration(days: daysToAdd));

      case TimeType.monthly:
        int targetDay = day ?? 1;
        int nextMonth = base.month + 1;
        int nextYear = base.year;
        if (nextMonth > 12) {
          nextMonth = 1;
          nextYear++;
        }
        return _clampDate(nextYear, nextMonth, targetDay);

      case TimeType.annual:
        int targetMonth = month ?? 1;
        int targetDay = day ?? 1;
        int nextYear = base.year + 1;
        return _clampDate(nextYear, targetMonth, targetDay);
    }
  }

  DateTime _clampDate(int year, int month, int day) {
    int maxDays = DateTime(year, month + 1, 0).day;
    int safeDay = day > maxDays ? maxDays : day;
    return DateTime(year, month, safeDay);
  }

  int _getWeekdayFromDayName(DayName dName) {
    switch (dName) {
      case DayName.monday:
        return DateTime.monday;
      case DayName.tuesday:
        return DateTime.tuesday;
      case DayName.wednesday:
        return DateTime.wednesday;
      case DayName.thursday:
        return DateTime.thursday;
      case DayName.friday:
        return DateTime.friday;
      case DayName.saturday:
        return DateTime.saturday;
      case DayName.sunday:
        return DateTime.sunday;
    }
  }
}
