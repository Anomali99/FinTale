import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../controllers/bill_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/bills_dict.dart';
import '../../core/constants/menu_dict.dart';
import '../../features/bills/widgets/add_bill_modal.dart';
import '../../features/bills/widgets/add_debt_modal.dart';
import '../../models/bill_model.dart';
import '../../models/debt_model.dart';
import '../../widgets/custom_bottom_sheet.dart';
import 'widgets/bills_tab.dart';
import 'widgets/debts_tab.dart';
import 'widgets/template_tab.dart';

class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  void _openAddBillModal(BuildContext context) async {
    final result = await showModalBottomSheet<BillModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddBillModal();
      },
    );

    if (result != null && context.mounted) {
      context.read<BillController>().createBill(result);
    }
  }

  void _openAddDebtModal(BuildContext context) async {
    final result = await showModalBottomSheet<DebtModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddDebtModal();
      },
    );

    if (result != null && context.mounted) {
      context.read<BillController>().createDebt(result);
    }
  }

  void _showActionPopup(BuildContext context, bool isRpg) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (con) {
        return CustomBottomSheet(
          children: [
            BottomSheetChild(
              title: BillsDict.addTemplate.get(isRpg),
              subtitle: BillsDict.addTemplate.description ?? "",
              color: Colors.blueAccent,
              icon: BillsDict.addTemplate.icon(isRpg),
              onTap: () {
                Navigator.pop(con);
                _openAddBillModal(context);
              },
            ),
            BottomSheetChild(
              title: BillsDict.addDebt.get(isRpg),
              subtitle: BillsDict.addDebt.description ?? "",
              color: AppColors.error,
              icon: BillsDict.addDebt.icon(isRpg),
              onTap: () {
                Navigator.pop(con);
                _openAddDebtModal(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();
    final billController = context.watch<BillController>();
    final transactionController = context.watch<TransactionController>();

    final isRpg = settingsController.isRpgMode;

    final billTransaction = transactionController.billTransaction;
    final bills = billController.bills;
    final debts = billController.debts;

    return DefaultTabController(
      length: 3,
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
          children: [
            BillsTab(data: billTransaction, isRpg: isRpg),
            TemplateTab(data: bills, isRpg: isRpg),
            DebtsTab(data: debts, isRpg: isRpg),
          ],
        ),
      ),
    );
  }
}
