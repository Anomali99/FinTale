import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/constants/screen_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/number_utils.dart';

class BalanceCard extends StatelessWidget {
  final bool isRpg;
  final Decimal totalBalance;
  final Decimal unallocatedBalance;
  final Decimal reservedBalance;

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

  String _formatBalance(Decimal amount) {
    if (isHideBalance) return 'Rp ********';
    return NumberUtils.toIdr(amount);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: showWallets,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.surfaceContainerHighest,
                    colorScheme.surface,
                  ],
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
                        ScreenDict.homeTotalBalance.get(isRpg),
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: onToggleHideBalance,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 4,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Icon(
                            isHideBalance
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Text(
                    _formatBalance(totalBalance),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 5),
                  Divider(color: colorScheme.onSurface.withOpacity(0.1)),
                  const SizedBox(height: 6),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ScreenDict.homePending.get(isRpg),
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatBalance(unallocatedBalance),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: unallocatedBalance > Decimal.zero
                                    ? AppColors.getSuccess(context)
                                    : colorScheme.onSurface,
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
                              ScreenDict.homeSavings.get(isRpg),
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatBalance(reservedBalance),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.getWarning(context),
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
              color: colorScheme.primary.withOpacity(0.05),
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
                              UiDict.income.icon(isRpg),
                              color: AppColors.getSuccess(context),
                              size: 14,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              UiDict.income.get(isRpg),
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
                  VerticalDivider(
                    color: colorScheme.onSurface.withOpacity(0.1),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: openTransfer,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(
                              UiDict.transfer.icon(isRpg),
                              color: AppColors.getWarning(context),
                              size: 14,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              UiDict.transfer.get(isRpg),
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
