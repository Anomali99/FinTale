import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dictionary.dart';
import '../../core/theme/mode_provider.dart';
import 'widgets/active_quest_tab.dart';
import 'widgets/boss_raid_tab.dart';
import 'widgets/master_log_sheet.dart';

class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  void _showMasterLog(BuildContext context, bool isRpg) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MasterLogSheet(isRpg: isRpg),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRpg = Provider.of<ModeProvider>(context).isRpgMode;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppDictionary.bills.get(isRpg),
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: FaIcon(AppDictionary.manageBillsIcon.get(isRpg), size: 20),
              onPressed: () => _showMasterLog(context, isRpg),
            ),
            const SizedBox(width: 8),
          ],
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: AppDictionary.currentBills.get(isRpg)),
              Tab(text: AppDictionary.totalDebts.get(isRpg)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ActiveQuestTab(isRpg: isRpg),
            BossRaidTab(isRpg: isRpg),
          ],
        ),
      ),
    );
  }
}
