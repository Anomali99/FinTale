import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/assets_dict.dart';
import '../../core/constants/invest_dict.dart';
import '../../core/constants/menu_dict.dart';
import '../../core/dummy/dummy_data.dart';
import '../../core/theme/mode_provider.dart';
import '../../models/assets_model.dart';
import '../../widgets/custom_button.dart';
import 'widgets/asset_tab.dart';
import 'widgets/total_card.dart';

class InvestScreen extends StatefulWidget {
  const InvestScreen({super.key});

  @override
  State<InvestScreen> createState() => _InvestScreenState();
}

class _InvestScreenState extends State<InvestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<AssetsModel> assets = DummyData.assets;
  late List<AssetsModel> lowRisk = [];
  late List<AssetsModel> mediumRisk = [];
  late List<AssetsModel> highRisk = [];

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

  void _showRecruitDialog(bool isRpg) {
    String selectedCategory = 'Tanker';
    String selectedType = 'Reksa Dana Pasar Uang';

    final Map<String, List<String>> typeOptions = {
      'Tanker': [
        'Reksa Dana Pasar Uang',
        'Obligasi Negara',
        'Deposito',
        'Lainnya',
      ],
      'Fighter': ['Saham Bluechip', 'Saham Dividen', 'Reksa Dana Saham', 'ETF'],
      'Assassin': ['Crypto Bitcoin', 'Crypto Altcoin', 'P2P Lending', 'Forex'],
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    InvestDict.add.get(isRpg),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Class (Risiko)',
                    ),
                    dropdownColor: AppColors.surfaceVariant,
                    items: ['Tanker', 'Fighter', 'Assassin']
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                    onChanged: (val) {
                      setModalState(() {
                        selectedCategory = val!;
                        selectedType = typeOptions[val]!.first;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Spesifikasi Senjata',
                    ),
                    dropdownColor: AppColors.surfaceVariant,
                    items: typeOptions[selectedCategory]!
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                    onChanged: (val) {
                      setModalState(() => selectedType = val!);
                    },
                  ),
                  const SizedBox(height: 16),

                  const TextField(
                    decoration: InputDecoration(labelText: 'Nama Pasukan/Aset'),
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Modal Awal',
                      prefixText: 'Rp ',
                    ),
                  ),

                  const SizedBox(height: 32),

                  CustomButton(
                    color: AppColors.primary,
                    icon: InvestDict.add.icon(isRpg),
                    title: InvestDict.add.get(isRpg),
                    onTap: () => Navigator.pop(context),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRpg = Provider.of<ModeProvider>(context).isRpgMode;
    BigInt totalInvested = BigInt.zero;
    BigInt totalValue = BigInt.zero;

    for (AssetsModel asset in assets) {
      totalInvested += asset.invested;
      totalValue += asset.value;

      switch (asset.type) {
        case RiskType.low:
          lowRisk.add(asset);
          break;
        case RiskType.medium:
          mediumRisk.add(asset);
          break;
        case RiskType.high:
          highRisk.add(asset);
          break;
      }
    }

    double overallPercentage() {
      if (totalInvested == BigInt.zero) return 0.0;
      double current = totalValue.toDouble();
      double capital = totalInvested.toDouble();
      return (((current - capital) / capital) * 100).abs();
    }

    bool isOverallProfit = totalValue > totalInvested;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          MenuDict.invest.get(isRpg),
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: FaIcon(InvestDict.add.icon(isRpg), size: 20),
            onPressed: () => _showRecruitDialog(isRpg),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: TotalCard(
              isProvit: isOverallProfit,
              totalCapital: totalInvested,
              totalCurrent: totalValue,
              percentage: overallPercentage(),
              isRpg: isRpg,
            ),
          ),

          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(
                icon: FaIcon(AssetsDict.lowRisk.icon(isRpg), size: 16),
                text: AssetsDict.lowRisk.get(isRpg),
              ),
              Tab(
                icon: FaIcon(AssetsDict.mediumRisk.icon(isRpg), size: 16),
                text: AssetsDict.mediumRisk.get(isRpg),
              ),
              Tab(
                icon: FaIcon(AssetsDict.highRisk.icon(isRpg), size: 16),
                text: AssetsDict.highRisk.get(isRpg),
              ),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                AssetTab(
                  icon: AssetsDict.lowRisk.icon(isRpg),
                  assets: lowRisk,
                  isRpg: isRpg,
                ),
                AssetTab(
                  icon: AssetsDict.mediumRisk.icon(isRpg),
                  assets: mediumRisk,
                  isRpg: isRpg,
                ),
                AssetTab(
                  icon: AssetsDict.highRisk.icon(isRpg),
                  assets: highRisk,
                  isRpg: isRpg,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
