import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dictionary.dart';
import '../../../core/utils/currency_formatter.dart';

class ActiveQuestTab extends StatelessWidget {
  final bool isRpg;

  const ActiveQuestTab({super.key, required this.isRpg});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        Text(
          AppDictionary.pending.get(isRpg).toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),

        _buildQuestCard(
          title: 'Listrik Rumah',
          dueDate: 'Due in 2 days',
          amount: 250000,
          icon: FontAwesomeIcons.bolt,
          isUrgent: true,
          isCleared: false,
        ),

        _buildQuestCard(
          title: 'Cicilan KPR Bulan ke-12',
          dueDate: 'Due in 15 days',
          amount: 1500000,
          icon: FontAwesomeIcons.houseUser,
          isUrgent: false,
          isCleared: false,
        ),

        const SizedBox(height: 32),

        Row(
          children: [
            const Expanded(child: Divider(color: Colors.white10)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                AppDictionary.paid.get(isRpg).toUpperCase(),
                style: const TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Expanded(child: Divider(color: Colors.white10)),
          ],
        ),
        const SizedBox(height: 12),

        _buildQuestCard(
          title: 'Internet WiFi',
          dueDate: 'Paid on 2 May',
          amount: 300000,
          icon: FontAwesomeIcons.wifi,
          isUrgent: false,
          isCleared: true,
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildQuestCard({
    required String title,
    required String dueDate,
    required double amount,
    required FaIconData icon,
    required bool isUrgent,
    required bool isCleared,
  }) {
    final Color cardColor = isCleared
        ? AppColors.surfaceVariant.withOpacity(0.5)
        : AppColors.surfaceVariant;
    final Color textColor = isCleared
        ? AppColors.textSecondary
        : AppColors.textPrimary;
    final Color accentColor = isCleared
        ? AppColors.success
        : (isUrgent ? AppColors.error : AppColors.primary);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withOpacity(isCleared ? 0.2 : 0.5),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          /* TODO: Buka BottomSheet Detail / Edit Tagihan */
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: accentColor.withOpacity(0.2),
                child: FaIcon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              decoration: isCleared
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dueDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: isCleared
                            ? AppColors.textSecondary
                            : accentColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              if (!isCleared) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.convertToIdr(amount),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 32,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          /* TODO: Logika Pembayaran */
                        },
                        icon: FaIcon(
                          AppDictionary.payBillIcon.get(isRpg),
                          size: 12,
                        ),
                        label: Text(
                          isRpg ? 'Attack' : 'Pay',
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor.withOpacity(0.2),
                          foregroundColor: accentColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                FaIcon(
                  AppDictionary.paidIcon.get(isRpg),
                  color: AppColors.success,
                  size: 28,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
