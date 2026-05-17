import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/category_dict.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/bill_model.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_table.dart';

enum BillActionType { payDirect, generateDraft, edit }

class BillDetailModal extends StatelessWidget {
  final BillModel bill;
  final bool isRpg;

  const BillDetailModal({super.key, required this.bill, required this.isRpg});

  String _getScheduleText() {
    switch (bill.type) {
      case TimeType.daily:
        return 'Setiap Hari';
      case TimeType.weekly:
        String dayNameStr = bill.dayName?.name ?? '';
        if (dayNameStr.isNotEmpty) {
          dayNameStr = dayNameStr[0].toUpperCase() + dayNameStr.substring(1);
        }
        return 'Mingguan (Setiap $dayNameStr)';
      case TimeType.monthly:
        return 'Bulanan (Tgl ${bill.day ?? '-'})';
      case TimeType.annual:
        return 'Tahunan (Tgl ${bill.day ?? '-'} Bulan ${bill.month ?? '-'})';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color mainColor = bill.tier.color;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: mainColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    bill.debtId == null
                        ? CategoryDict.utilities.icon(isRpg)
                        : CategoryDict.debtInstallment.icon(isRpg),
                    size: 28,
                    color: mainColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: mainColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: mainColor.withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              bill.tier.rank,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: mainColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (!bill.isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'NONAKTIF',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bill.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomTable(
              color: AppColors.surfaceVariant,
              borderColor: mainColor,
              children: [
                CustomRowTable(
                  label: 'Nominal Tagihan',
                  value: CurrencyFormatter.convertToIdr(bill.amount),
                  valueColor: AppColors.textPrimary,
                  boldValue: true,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Colors.white10, height: 1),
                ),
                CustomRowTable(
                  label: 'Siklus Pembayaran',
                  value: _getScheduleText(),
                ),
                const SizedBox(height: 12),
                CustomRowTable(
                  label: 'Jatuh Tempo Berikutnya',
                  value: bill.nextDueDate != null
                      ? DateFormat('EEEE, dd MMM yyyy').format(
                          DateTime.fromMillisecondsSinceEpoch(
                            bill.nextDueDate!,
                          ),
                        )
                      : 'Belum dijadwalkan',
                  valueColor: AppColors.primary,
                  boldValue: true,
                ),
                const SizedBox(height: 12),
                CustomRowTable(
                  label: 'Tipe',
                  value: bill.debtId != null
                      ? 'Cicilan Hutang'
                      : 'Tagihan Rutin',
                  valueColor: bill.debtId != null
                      ? AppColors.error
                      : Colors.blueAccent,
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (bill.isActive) ...[
              CustomButton(
                title: 'Bayar Sekarang',
                color: AppColors.primary,
                onTap: () {
                  Navigator.pop(context, BillActionType.payDirect);
                },
              ),
              const SizedBox(height: 12),

              CustomButton(
                title: 'Generate Tagihan (Draf)',
                color: Colors.orange,
                onTap: () {
                  Navigator.pop(context, BillActionType.generateDraft);
                },
              ),
              const SizedBox(height: 12),
            ] else ...[
              const Center(
                child: Text(
                  'Tagihan ini sedang dinonaktifkan.\nAktifkan melalui mode Edit untuk membayar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
            ],

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  side: const BorderSide(color: AppColors.textSecondary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context, BillActionType.edit);
                },
                child: const Text(
                  'Edit Tagihan',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
