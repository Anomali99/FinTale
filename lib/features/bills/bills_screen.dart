import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/bills_dict.dart';
import '../../core/constants/menu_dict.dart';
import '../../core/theme/mode_provider.dart';
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
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent.withOpacity(0.2),
                  child: FaIcon(
                    BillsDict.addTemplate.icon(isRpg),
                    color: Colors.blueAccent,
                    size: 18,
                  ),
                ),
                title: Text(
                  BillsDict.addTemplate.get(isRpg),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(BillsDict.addTemplate.decription ?? ''),
                onTap: () {
                  Navigator.pop(context);
                  /* TODO: Navigasi ke form tambah quest */
                },
              ),
              const Divider(color: Colors.white10),

              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.error.withOpacity(0.2),
                  child: FaIcon(
                    BillsDict.addDebt.icon(isRpg),
                    color: AppColors.error,
                    size: 18,
                  ),
                ),
                title: Text(
                  BillsDict.addDebt.get(isRpg),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(BillsDict.addDebt.decription ?? ''),
                onTap: () {
                  Navigator.pop(context);
                  /* TODO: Navigasi ke form tambah hutang/boss */
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
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
            BillsTab(isRpg: isRpg),
            TemplateTab(isRpg: isRpg),
            DebtsTab(isRpg: isRpg),
          ],
        ),
      ),
    );
  }
}
