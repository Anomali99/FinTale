import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dictionary.dart';
import '../../core/theme/mode_provider.dart';
import '../../core/utils/currency_formatter.dart';

class AssetModel {
  final String id;
  String name;
  String category;
  String type;
  double investedCapital;
  double currentValue;
  double unitCount;
  String unitName;

  AssetModel({
    required this.id,
    required this.name,
    required this.category,
    required this.type,
    required this.investedCapital,
    required this.currentValue,
    required this.unitCount,
    required this.unitName,
  });

  double get profitPercentage {
    if (investedCapital == 0) return 0;
    return ((currentValue - investedCapital) / investedCapital);
  }
}

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

  void _showClaimDividendDialog(AssetModel asset, bool isRpg) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceVariant,
        title: Row(
          children: [
            FaIcon(
              AppDictionary.dividendIcon.get(isRpg),
              color: AppColors.success,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(AppDictionary.claimDividend.get(isRpg)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Berapa hasil/dividen yang diberikan oleh ${asset.name}?',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nominal (Rp)',
                prefixText: 'Rp ',
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.success),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Berhasil! Dividen masuk ke saldo Cash Anda.'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Klaim', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showScoutReportDialog(AssetModel asset, bool isRpg) {
    final TextEditingController valueController = TextEditingController(
      text: asset.currentValue.toStringAsFixed(0),
    );
    final TextEditingController unitController = TextEditingController(
      text: asset.unitCount.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceVariant,
        title: Row(
          children: [
            FaIcon(
              AppDictionary.scoutIcon.get(isRpg),
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(AppDictionary.scoutReport.get(isRpg)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: valueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: AppDictionary.currentValue.get(isRpg),
                prefixText: 'Rp ',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: unitController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Sisa Pasukan (${asset.unitName})',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              setState(() {
                asset.currentValue =
                    double.tryParse(valueController.text) ?? asset.currentValue;
                asset.unitCount =
                    double.tryParse(unitController.text) ?? asset.unitCount;
              });
              Navigator.pop(context);
            },
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTacticalRetreatDialog(AssetModel asset, bool isRpg) {
    final TextEditingController lootController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceVariant,
        title: Row(
          children: [
            FaIcon(
              AppDictionary.retreatIcon.get(isRpg),
              color: AppColors.warning,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(AppDictionary.retreat.get(isRpg)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tarik dana dari ${asset.name}. Total saat ini: ${CurrencyFormatter.convertToIdr(asset.currentValue)}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: lootController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nominal yang ditarik',
                prefixText: 'Rp ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            onPressed: () {
              double withdrawn = double.tryParse(lootController.text) ?? 0;
              if (withdrawn > 0 && withdrawn <= asset.currentValue) {
                double ratio = asset.investedCapital / asset.currentValue;
                double capitalWithdrawn = withdrawn * ratio;
                double profitRealized = withdrawn - capitalWithdrawn;

                setState(() {
                  asset.currentValue -= withdrawn;
                  asset.investedCapital -= capitalWithdrawn;
                  if (asset.investedCapital < 0) asset.investedCapital = 0;
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.success,
                    content: Text(
                      'Tarik Dana Berhasil!\nModal Ditarik: ${CurrencyFormatter.convertToIdr(capitalWithdrawn)}\nProfit Direalisasikan: ${CurrencyFormatter.convertToIdr(profitRealized)}',
                    ),
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            },
            child: const Text('Tarik', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
                    AppDictionary.recruit.get(isRpg),
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
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Rekrut Pasukan',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
        title: Row(
          children: [
            FaIcon(
              AppDictionary.investIcon.get(isRpg),
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Text(
              AppDictionary.invest.get(isRpg),
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.surfaceVariant, AppColors.surface],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isOverallProfit
                      ? AppColors.success.withOpacity(0.3)
                      : AppColors.error.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppDictionary.totalPortfolio.get(isRpg),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyFormatter.convertToIdr(totalCurrent),
                    style: GoogleFonts.montserrat(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isOverallProfit
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppDictionary.investedCapital.get(isRpg),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.convertToIdr(totalCapital),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isOverallProfit
                              ? AppColors.success.withOpacity(0.2)
                              : AppColors.error.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            FaIcon(
                              isOverallProfit
                                  ? FontAwesomeIcons.arrowTrendUp
                                  : FontAwesomeIcons.arrowTrendDown,
                              color: isOverallProfit
                                  ? AppColors.success
                                  : AppColors.error,
                              size: 12,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${isOverallProfit ? '+' : ''}${(overallPercentage * 100).toStringAsFixed(2)}%',
                              style: TextStyle(
                                color: isOverallProfit
                                    ? AppColors.success
                                    : AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(
                icon: FaIcon(AppDictionary.tankerIcon.get(isRpg), size: 16),
                text: 'Tanker',
              ),
              Tab(
                icon: FaIcon(AppDictionary.fighterIcon.get(isRpg), size: 16),
                text: 'Fighter',
              ),
              Tab(
                icon: FaIcon(AppDictionary.assassinIcon.get(isRpg), size: 16),
                text: 'Assassin',
              ),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAssetList('Tanker', isRpg),
                _buildAssetList('Fighter', isRpg),
                _buildAssetList('Assassin', isRpg),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRecruitDialog(isRpg),
        backgroundColor: AppColors.primary,
        icon: FaIcon(AppDictionary.recruitIcon.get(isRpg), size: 18),
        label: Text(
          AppDictionary.recruit.get(isRpg),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildAssetList(String category, bool isRpg) {
    final filteredAssets = _assets
        .where((asset) => asset.category == category)
        .toList();

    if (filteredAssets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              category == 'Assassin'
                  ? FontAwesomeIcons.userNinja
                  : (category == 'Fighter'
                        ? FontAwesomeIcons.handFist
                        : FontAwesomeIcons.shieldHalved),
              size: 48,
              color: AppColors.surfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              AppDictionary.emptyAsset.get(isRpg),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 24.0,
        bottom: 100.0,
      ),
      itemCount: filteredAssets.length,
      itemBuilder: (context, index) {
        final asset = filteredAssets[index];
        final isProfit = asset.profitPercentage >= 0;

        return Container(
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
                    child: FaIcon(
                      category == 'Tanker'
                          ? AppDictionary.tankerIcon.get(isRpg)
                          : (category == 'Fighter'
                                ? AppDictionary.fighterIcon.get(isRpg)
                                : AppDictionary.assassinIcon.get(isRpg)),
                      size: 14,
                      color: AppColors.primary,
                    ),
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
                          '${asset.unitCount} ${asset.unitName} • ${asset.type}',
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
                          color: isProfit
                              ? AppColors.success.withOpacity(0.2)
                              : AppColors.error.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${isProfit ? '+' : ''}${(asset.profitPercentage * 100).toStringAsFixed(2)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isProfit
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: 24,
                    width: 24,
                    child: PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      icon: const FaIcon(
                        FontAwesomeIcons.ellipsisVertical,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      color: AppColors.surface,
                      onSelected: (value) {
                        if (value == 'dividend')
                          _showClaimDividendDialog(asset, isRpg);
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'dividend',
                          child: Text(AppDictionary.claimDividend.get(isRpg)),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit Data'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Hapus Pasukan',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
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
                        AppDictionary.investedCapital.get(isRpg),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.convertToIdr(asset.investedCapital),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        AppDictionary.currentValue.get(isRpg),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.convertToIdr(asset.currentValue),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: isProfit ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(color: Colors.white10, height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showScoutReportDialog(asset, isRpg),
                      icon: FaIcon(
                        AppDictionary.scoutIcon.get(isRpg),
                        size: 14,
                        color: AppColors.primary,
                      ),
                      label: Text(
                        AppDictionary.scoutReport.get(isRpg),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showTacticalRetreatDialog(asset, isRpg),
                      icon: FaIcon(
                        AppDictionary.retreatIcon.get(isRpg),
                        size: 14,
                        color: AppColors.warning,
                      ),
                      label: Text(
                        AppDictionary.retreat.get(isRpg),
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontSize: 12,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning.withOpacity(0.2),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
