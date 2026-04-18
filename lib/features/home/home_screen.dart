import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dictionary.dart';
import '../../core/theme/mode_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../widgets/mana_bar.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showWalletDetails(BuildContext context, bool isRpg) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: ListView(
                controller: controller,
                children: [
                  Text(
                    AppDictionary.walletDetails.get(isRpg),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSimpleWalletItem(
                    icon: FontAwesomeIcons.coins,
                    name: AppDictionary.cash.get(isRpg),
                    amount: 1500000,
                  ),
                  const Divider(color: Colors.white10, height: 32),

                  Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.surfaceVariant,
                        child: FaIcon(
                          FontAwesomeIcons.buildingColumns,
                          size: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      title: Text(
                        AppDictionary.bankAccount.get(isRpg),
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: Text(
                        CurrencyFormatter.convertToIdr(10000000),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      children: [
                        _buildSubWalletItem(name: 'Bank BCA', amount: 8000000),
                        _buildSubWalletItem(
                          name: 'Bank Mandiri',
                          amount: 2000000,
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 16),

                  Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.surfaceVariant,
                        child: FaIcon(
                          FontAwesomeIcons.mobileScreen,
                          size: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      title: Text(
                        AppDictionary.eWallet.get(isRpg),
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: Text(
                        CurrencyFormatter.convertToIdr(500000),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      children: [
                        _buildSubWalletItem(name: 'GoPay', amount: 350000),
                        _buildSubWalletItem(name: 'OVO', amount: 150000),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.add, color: AppColors.primary),
                      label: Text(
                        'Add New ${isRpg ? 'Storage' : 'Wallet'}',
                        style: const TextStyle(color: AppColors.primary),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSimpleWalletItem({
    required FaIconData icon,
    required String name,
    required double amount,
  }) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.surfaceVariant,
          child: FaIcon(icon, size: 16, color: AppColors.textPrimary),
        ),
        const SizedBox(width: 16),
        Expanded(child: Text(name, style: const TextStyle(fontSize: 16))),
        Text(
          CurrencyFormatter.convertToIdr(amount),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildSubWalletItem({required String name, required double amount}) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 56.0,
        top: 8.0,
        bottom: 8.0,
        right: 8.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: TextStyle(color: AppColors.textSecondary)),
          Text(
            CurrencyFormatter.convertToIdr(amount),
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRpg = Provider.of<ModeProvider>(context).isRpgMode;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lv. 5 - Fatiq',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              AppDictionary.noviceSaver.get(isRpg),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.gear, size: 20),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _showWalletDetails(context, isRpg),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.surfaceVariant, AppColors.surface],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppDictionary.totalBalance.get(isRpg),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              const Icon(
                                Icons.visibility,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            CurrencyFormatter.convertToIdr(12000000),
                            style: GoogleFonts.montserrat(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              /* TODO: Aksi Pemasukan */
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(
                                  AppDictionary.incomeIcon.get(isRpg),
                                  color: AppColors.success,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AppDictionary.income.get(isRpg),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const VerticalDivider(
                          color: Colors.white24,
                          thickness: 1,
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              /* TODO: Aksi Transfer */
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(
                                  AppDictionary.transferIcon.get(isRpg),
                                  color: AppColors.warning,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AppDictionary.transfer.get(isRpg),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          Text(
            AppDictionary.dailyLimit.get(isRpg),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const ManaBar(limit: 200000, spent: 50000),

          const SizedBox(height: 32),

          Text(
            AppDictionary.upcomingBills.get(isRpg),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                const FaIcon(FontAwesomeIcons.bolt, color: AppColors.error),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Listrik Bulan Ini',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Due in 2 Days',
                        style: TextStyle(color: AppColors.error, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  CurrencyFormatter.convertToIdr(350000),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
