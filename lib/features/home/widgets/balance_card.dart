import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/home_dict.dart';
import '../../../core/constants/shared_dict.dart';
import '../../../core/utils/currency_formatter.dart';

class BalanceCard extends StatelessWidget {
  final bool isRpg;
  final BigInt totalBalance;
  final BigInt unallocatedBalance;
  final BigInt reservedBalance;

  final bool isHideBalance;
  final VoidCallback onToggleHideBalance;
  final VoidCallback showWallets;
  final VoidCallback openAddIncome;
  final VoidCallback openTransfer;

  const BalanceCard({
    super.key,
    required this.totalBalance,
    required this.unallocatedBalance,
    required this.reservedBalance,
    required this.isHideBalance,
    required this.onToggleHideBalance,
    required this.showWallets,
    required this.openAddIncome,
    required this.openTransfer,
    required this.isRpg,
  });

  String _formatBalance(BigInt amount) {
    if (isHideBalance) return 'Rp ********';
    return CurrencyFormatter.convertToIdr(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: showWallets,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.surfaceVariant, AppColors.surface],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        HomeDict.totalBalance.get(isRpg),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          isHideBalance
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        onPressed: onToggleHideBalance,
                      ),
                    ],
                  ),

                  Text(
                    _formatBalance(totalBalance),
                    style: GoogleFonts.montserrat(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 10),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isRpg ? "Unassigned Loot" : "Belum Dialokasi",
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatBalance(unallocatedBalance),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: unallocatedBalance > BigInt.zero
                                    ? AppColors.success
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              isRpg ? "Reserved / Savings" : "Total Tabungan",
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatBalance(reservedBalance),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: openAddIncome,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(
                              SharedDict.income.icon(isRpg),
                              color: AppColors.success,
                              size: 14,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              SharedDict.income.get(isRpg),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(color: Colors.white10),
                  Expanded(
                    child: InkWell(
                      onTap: openTransfer,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(
                              SharedDict.transfer.icon(isRpg),
                              color: AppColors.warning,
                              size: 14,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              SharedDict.transfer.get(isRpg),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
