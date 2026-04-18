import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

class BossRaidTab extends StatelessWidget {
  final bool isRpg;

  const BossRaidTab({super.key, required this.isRpg});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        _buildBossCard(
          bossName: 'KPR Bank BCA',
          bossLevel: 'Lv. 99',
          currentHp: 200000000,
          maxHp: 300000000,
          icon: FontAwesomeIcons.buildingColumns,
        ),
        _buildBossCard(
          bossName: 'Pinjaman Teman (Rio)',
          bossLevel: 'Lv. 10',
          currentHp: 1500000,
          maxHp: 5000000,
          icon: FontAwesomeIcons.handshake,
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildBossCard({
    required String bossName,
    required String bossLevel,
    required double currentHp,
    required double maxHp,
    required FaIconData icon,
  }) {
    final double hpPercentage = maxHp > 0
        ? (currentHp / maxHp).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: FaIcon(icon, color: AppColors.error, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bossLevel,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      bossName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isRpg ? 'HP Remaining' : 'Remaining Debt',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                CurrencyFormatter.convertToIdr(currentHp),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: hpPercentage,
              backgroundColor: AppColors.background,
              color: AppColors.error,
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Total: ${CurrencyFormatter.convertToIdr(maxHp)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
