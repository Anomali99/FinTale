import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/invest_dict.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/assets_model.dart';
import '../../../widgets/custom_bottom_sheet.dart';

class InvestCard extends StatelessWidget {
  final bool isRpg;
  final FaIconData icon;
  final AssetsModel asset;

  const InvestCard({
    super.key,
    required this.icon,
    required this.asset,
    required this.isRpg,
  });

  void _showAssetOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (con) {
        return CustomBottomSheet(
          title: asset.name,
          hideDriver: true,
          children: [
            BottomSheetChild(
              title: 'Beli Lagi (Tambah Modal)',
              color: AppColors.primary,
              icon: FontAwesomeIcons.plus,
              onTap: () {
                Navigator.pop(con);
              },
            ),
            BottomSheetChild(
              title: 'Perbarui Harga Pasar',
              color: Colors.blueAccent,
              icon: FontAwesomeIcons.arrowsRotate,
              onTap: () {
                Navigator.pop(con);
              },
            ),
            BottomSheetChild(
              title: 'Klaim Dividen / Bunga',
              color: AppColors.success,
              icon: FontAwesomeIcons.moneyCheck,
              onTap: () {
                Navigator.pop(con);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showAssetOptions(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: FaIcon(icon, size: 14, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${asset.unit} ${asset.unitName} • ${asset.category.value}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: asset.isProfit
                            ? AppColors.success.withOpacity(0.2)
                            : AppColors.error.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${asset.isProfit ? '+' : '-'} ${asset.getPercentage.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: asset.isProfit
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      InvestDict.invested.get(isRpg),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.convertToIdr(asset.invested),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      InvestDict.value.get(isRpg),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.convertToIdr(asset.value),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: asset.isProfit
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
