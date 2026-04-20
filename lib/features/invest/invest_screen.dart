import 'package:fintale/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dictionary.dart';
import '../../core/theme/mode_provider.dart';
import 'widgets/asset_tab.dart';
import 'widgets/invest_card.dart';
import 'widgets/total_card.dart';

class InvestScreen extends StatefulWidget {
  const InvestScreen({super.key});

  @override
  State<InvestScreen> createState() => _InvestScreenState();
}

class _InvestScreenState extends State<InvestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<AssetModel> _assets = [
    AssetModel(
      id: '1',
      name: 'Reksadana Sucor',
      category: 'Tanker',
      type: 'Reksa Dana Pasar Uang',
      investedCapital: 5000000,
      currentValue: 5200000,
      unitCount: 3450.5,
      unitName: 'Unit',
    ),
    AssetModel(
      id: '2',
      name: 'BBCA',
      category: 'Fighter',
      type: 'Saham Bluechip',
      investedCapital: 10000000,
      currentValue: 11500000,
      unitCount: 50,
      unitName: 'Lot',
    ),
    AssetModel(
      id: '3',
      name: 'Ethereum (ETH)',
      category: 'Assassin',
      type: 'Crypto Altcoin',
      investedCapital: 2000000,
      currentValue: 1800000,
      unitCount: 0.045,
      unitName: 'ETH',
    ),
  ];

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
                    InvestDict.recruit.get(isRpg),
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
                    icon: InvestDict.recruitIcon.get(isRpg),
                    title: InvestDict.recruit.get(isRpg),
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

    double totalCapital = _assets.fold(
      0,
      (sum, item) => sum + item.investedCapital,
    );
    double totalCurrent = _assets.fold(
      0,
      (sum, item) => sum + item.currentValue,
    );
    double totalProfit = totalCurrent - totalCapital;
    double overallPercentage = totalCapital > 0
        ? (totalProfit / totalCapital)
        : 0;
    bool isOverallProfit = totalProfit >= 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          MenuDict.invest.get(isRpg),
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: FaIcon(InvestDict.recruitIcon.get(isRpg), size: 20),
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
              totalCapital: totalCapital,
              totalCurrent: totalCurrent,
              percentage: overallPercentage,
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
                icon: FaIcon(ArmoryDict.tankerIcon.get(isRpg), size: 16),
                text: ArmoryDict.tanker.get(isRpg),
              ),
              Tab(
                icon: FaIcon(ArmoryDict.fighterIcon.get(isRpg), size: 16),
                text: ArmoryDict.fighter.get(isRpg),
              ),
              Tab(
                icon: FaIcon(ArmoryDict.assassinIcon.get(isRpg), size: 16),
                text: ArmoryDict.assassin.get(isRpg),
              ),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                AssetTab(
                  icon: ArmoryDict.tankerIcon.get(isRpg),
                  category: 'Tanker',
                  assets: [_assets[0]],
                  isRpg: isRpg,
                ),
                AssetTab(
                  icon: ArmoryDict.fighterIcon.get(isRpg),
                  category: 'Fighter',
                  assets: [_assets[1]],
                  isRpg: isRpg,
                ),
                AssetTab(
                  icon: ArmoryDict.assassinIcon.get(isRpg),
                  category: 'Assassin',
                  assets: [_assets[2]],
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
