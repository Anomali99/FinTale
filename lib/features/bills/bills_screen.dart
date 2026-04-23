import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/bills_dict.dart';
import '../../core/constants/menu_dict.dart';
import '../../core/dummy/dummy_data.dart';
import '../../core/theme/mode_provider.dart';
import '../../models/bill_model.dart';
import '../../models/debt_model.dart';
import '../../models/transaction_model.dart';
import '../../widgets/custom_bottom_sheet.dart';
import 'widgets/bills_tab.dart';
import 'widgets/debts_tab.dart';
import 'widgets/template_tab.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<DebtModel> debts = DummyData.debts;
  final List<BillModel> bills = DummyData.bills;
  final List<TransactionModel> transactions = DummyData.transactions
      .where((transaction) => transaction.billId != null)
      .toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showActionPopup(BuildContext context, bool isRpg) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CustomBottomSheet(
          children: [
            BottomSheetChild(
              title: BillsDict.addTemplate.get(isRpg),
              subtitle: BillsDict.addTemplate.decription ?? "",
              color: Colors.blueAccent,
              icon: BillsDict.addTemplate.icon(isRpg),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            BottomSheetChild(
              title: BillsDict.addDebt.get(isRpg),
              subtitle: BillsDict.addDebt.decription ?? "",
              color: AppColors.error,
              icon: BillsDict.addDebt.icon(isRpg),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
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
            MenuDict.bills.get(isRpg),
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: FaIcon(BillsDict.addIcon.get(isRpg), size: 20),
              onPressed: () => _showActionPopup(context, isRpg),
            ),
            const SizedBox(width: 8),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: BillsDict.bills.get(isRpg)),
              Tab(text: BillsDict.template.get(isRpg)),
              Tab(text: BillsDict.debts.get(isRpg)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            BillsTab(data: transactions, isRpg: isRpg),
            TemplateTab(data: bills, isRpg: isRpg),
            DebtsTab(data: debts, isRpg: isRpg),
          ],
        ),
      ),
    );
  }
}
