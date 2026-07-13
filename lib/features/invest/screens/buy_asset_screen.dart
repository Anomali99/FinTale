import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/settings_controller.dart';
import '../../../core/constants/category_dict.dart';
import '../../../core/constants/screen_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/utils/enum_types.dart';
import '../../../core/utils/number_utils.dart';
import '../../../models/assets_model.dart';
import '../../../models/transaction_detail_model.dart';
import '../../../models/transaction_model.dart';
import '../../../models/wallet_model.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/note_container.dart';

class BuyAssetScreen extends StatefulWidget {
  final List<WalletModel> wallets;
  final AssetsModel? initialAsset;
  final RiskType? initialRisk;
  final List<AssetsModel> assets;
  final Decimal? pendingAllocation;
  final bool isEmergency;

  const BuyAssetScreen({
    super.key,
    required this.wallets,
    required this.assets,
    this.initialAsset,
    this.initialRisk,
    this.pendingAllocation,
    this.isEmergency = false,
  });

  @override
  State<BuyAssetScreen> createState() => _BuyAssetScreenState();
}

class _BuyAssetScreenState extends State<BuyAssetScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  final _nameController = TextEditingController();
  final _unitNameController = TextEditingController(text: 'Unit');
  final _feeController = TextEditingController(text: '0');
  final _unitAmountController = TextEditingController();
  final _priceController = TextEditingController();

  AssetsModel? _selectedAsset;
  WalletModel? _selectedWallet;
  AssetsCategory? _selectedCategory;
  RiskType? _selectedRisk;
  Decimal _amount = Decimal.zero;
  bool _isRoundedActive = false;
  bool _isReservedActive = false;
  bool _isDevidenActive = false;
  bool _isEmergencyActive = false;
  bool _isFeeActive = false;

  bool _isNewAssetTab = true;
  bool _isHideTab = false;
  bool _isLockRisk = false;
  bool _isLockWallet = false;

  Decimal get _cleanAssetAmount {
    Decimal cleanUnit = NumberUtils.parseToDecimal(_unitAmountController.text);
    Decimal cleanPrice = NumberUtils.parseToDecimal(_priceController.text);

    if (cleanUnit == Decimal.zero || cleanPrice == Decimal.zero) {
      return Decimal.zero;
    }

    return Decimal.parse(
      (cleanUnit.toDouble() * cleanPrice.toDouble()).toString(),
    );
  }

  @override
  void initState() {
    super.initState();

    int initialIndex = 0;
    if (widget.initialAsset != null) {
      initialIndex = 1;
      _selectedAsset = widget.initialAsset;
      _unitNameController.text = _selectedAsset!.unitName;
    }
    _isNewAssetTab = initialIndex == 0;

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: initialIndex,
    );

    if (widget.assets.isEmpty || widget.initialAsset != null) {
      _isHideTab = true;
    }

    if (widget.wallets.length == 1) {
      _isLockWallet = true;
      _selectedWallet = widget.wallets[0];
    }

    if (widget.initialRisk != null) {
      _isLockRisk = true;
      _selectedRisk = widget.initialRisk;
    }

    _isEmergencyActive = widget.isEmergency;

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _isNewAssetTab = _tabController.index == 0;
          _resetForm();
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _unitNameController.dispose();
    _unitAmountController.dispose();
    _priceController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _unitAmountController.text = '0';
    _priceController.text = '0';
    _feeController.text = '0';
    _amount = Decimal.zero;
    _isReservedActive = false;
    _isFeeActive = false;
    _isDevidenActive = false;
    if (_isNewAssetTab) {
      _unitNameController.text = 'Unit';
    } else {
      _unitNameController.text = _selectedAsset?.unitName ?? 'Unit';
    }
  }

  void _calculateTotal() {
    try {
      Decimal total = _cleanAssetAmount;
      if (_isFeeActive) {
        total += NumberUtils.parseToDecimal(_feeController.text);
      }
      if (_isRoundedActive) {
        total = total.ceil();
      }
      setState(() {
        _amount = total;
      });
    } catch (e) {
      _amount = Decimal.zero;
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Decimal cleanUnit = NumberUtils.parseToDecimal(
        _unitAmountController.text,
      );
      Decimal cleanAssetAmount = _cleanAssetAmount;

      AssetsModel assetToReturn;
      String transactionTitle;
      RiskType riskType;

      if (_isNewAssetTab) {
        riskType = _selectedRisk!;
        assetToReturn = AssetsModel(
          name: _nameController.text,
          type: riskType,
          category: _selectedCategory!,
          unitName: _unitNameController.text,
          hasDividend: _isDevidenActive,
          isEmergency: _isEmergencyActive,
          invested: cleanAssetAmount,
          value: cleanAssetAmount,
          unit: cleanUnit,
        );

        transactionTitle =
            '${ScreenDict.investBuyAsset.normal} ${assetToReturn.name}';
      } else {
        Decimal cleanPrice = NumberUtils.parseToDecimal(_priceController.text);
        Decimal newTotalUnit = _selectedAsset!.unit + cleanUnit;
        Decimal newTotalValue = Decimal.parse(
          (newTotalUnit.toDouble() * cleanPrice.toDouble()).toString(),
        );
        riskType = _selectedAsset!.type;
        assetToReturn = AssetsModel(
          id: _selectedAsset?.id,
          name: _selectedAsset!.name,
          type: riskType,
          category: _selectedAsset!.category,
          unitName: _selectedAsset!.unitName,
          invested: _selectedAsset!.invested + cleanAssetAmount,
          hasDividend: _selectedAsset!.hasDividend,
          isEmergency: _selectedAsset!.isEmergency,
          value: newTotalValue,
          unit: newTotalUnit,
        );

        transactionTitle =
            '${ScreenDict.investAddModal.normal} ${assetToReturn.name}';
      }

      List<TransactionDetailModel> details = [
        TransactionDetailModel(
          title: '${assetToReturn.name} $cleanUnit ${assetToReturn.unitName}',
          amount: cleanAssetAmount,
          category: TransactionCategory.getTransactionCategory(riskType),
          flow: FlowType.expense,
        ),
      ];

      if (_isFeeActive) {
        details.add(
          TransactionDetailModel(
            title: 'Fee',
            amount: NumberUtils.parseToDecimal(_feeController.text),
            category: TransactionCategory.utilities,
            flow: FlowType.expense,
          ),
        );
      }

      TransactionModel transaction = TransactionModel(
        type: TransactionType.expense,
        title: transactionTitle,
        amount: _amount,
        status: StatusType.paid,
        walletId: _selectedWallet?.id,
        assetsId: assetToReturn.id,
        detailTransaction: details,
        dateTimestamp: DateTime.now().millisecondsSinceEpoch,
      );

      Navigator.pop(context, {
        "asset": assetToReturn,
        "transaction": transaction,
        'use_reserved': _isReservedActive,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRpg = context.read<SettingsController>().isRpgMode;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          _isHideTab
              ? _isNewAssetTab
                    ? ScreenDict.investNewAsset.get(isRpg)
                    : ScreenDict.investAddModal.get(isRpg)
              : '${ScreenDict.investNewAsset.get(isRpg)} / ${ScreenDict.investAddModal.get(isRpg)}',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: _buildBottomBar(isRpg),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_isHideTab) ...[
                  Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.5),
                        ),
                      ),
                      labelColor: colorScheme.primary,
                      labelStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      unselectedLabelColor: colorScheme.onSurfaceVariant,
                      tabs: [
                        Tab(text: ScreenDict.investNewAsset.get(isRpg)),
                        Tab(text: ScreenDict.investAddModal.get(isRpg)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                if (_isNewAssetTab) ...[
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: UiDict.name,
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? UiDict.requiredName
                        : null,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<AssetsCategory>(
                    initialValue: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: UiDict.category,
                      border: OutlineInputBorder(),
                    ),
                    items: AssetsCategory.values
                        .map(
                          (cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(
                              cat.value,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val),
                    validator: (val) =>
                        val == null ? UiDict.requiredCategory : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<RiskType>(
                    initialValue: _selectedRisk,
                    decoration: InputDecoration(
                      labelText: ScreenDict.investRisk.get(isRpg),
                      border: OutlineInputBorder(),
                    ),
                    items: RiskType.values
                        .map(
                          (risk) => DropdownMenuItem(
                            value: risk,
                            child: Text(
                              CategoryDict.getAssetByEnum(
                                risk,
                              ).get(isRpg).toUpperCase(),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: !_isLockRisk
                        ? (val) => setState(() => _selectedRisk = val)
                        : null,
                    validator: (val) => val == null
                        ? ScreenDict.investRiskRequired.get(isRpg)
                        : null,
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  DropdownButtonFormField<AssetsModel>(
                    isExpanded: true,
                    menuMaxHeight: 300,
                    initialValue: _selectedAsset,
                    decoration: InputDecoration(
                      labelText: ScreenDict.investAsset.get(isRpg),
                      border: OutlineInputBorder(),
                    ),
                    items: widget.assets
                        .map(
                          (a) => DropdownMenuItem(
                            value: a,
                            child: Text(
                              a.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: widget.initialAsset == null
                        ? (val) => setState(() {
                            _selectedAsset = val;
                            _unitNameController.text = val?.unitName ?? 'Unit';
                          })
                        : null,
                    validator: (val) => val == null && !_isNewAssetTab
                        ? ScreenDict.investAssetRequired.get(isRpg)
                        : null,
                  ),
                  const SizedBox(height: 16),
                ],

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _unitAmountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: UiDict.amount,
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) => NumberUtils.formatInput(
                          _unitAmountController,
                          val,
                          isDecimal: true,
                          onCalculated: _calculateTotal,
                        ),
                        validator: (val) =>
                            val == null || !NumberUtils.isValidAmount(val)
                            ? UiDict.requiredAmount
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _unitNameController,
                        decoration: InputDecoration(
                          labelText: ScreenDict.investUnit.get(isRpg),
                          border: OutlineInputBorder(),
                        ),
                        readOnly: !_isNewAssetTab,
                        onChanged: (val) => setState(() {}),
                        validator: (val) => val == null || val.isEmpty
                            ? ScreenDict.investUnitRequired.get(isRpg)
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: ScreenDict.getInvestPricePerUnit(
                      _unitNameController.text,
                    ),
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => NumberUtils.formatInput(
                    _priceController,
                    val,
                    isDecimal: true,
                    onCalculated: _calculateTotal,
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? UiDict.requiredPrice : null,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<WalletModel>(
                  initialValue: _selectedWallet,
                  decoration: InputDecoration(
                    labelText: UiDict.sourceFunds,
                    border: OutlineInputBorder(),
                  ),
                  items: widget.wallets
                      .map(
                        (wallet) => DropdownMenuItem(
                          value: wallet,
                          child: Text(wallet.name),
                        ),
                      )
                      .toList(),
                  onChanged: !_isLockWallet
                      ? (val) => setState(() => _selectedWallet = val)
                      : null,
                  validator: (val) =>
                      val == null ? UiDict.requiredWallet : null,
                ),
                const SizedBox(height: 16),
                if (_isNewAssetTab) ...[
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      ScreenDict.getDevidenCheck(isRpg: isRpg),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      ScreenDict.getDevidenCheckDesc(isRpg: isRpg),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    value: _isDevidenActive,
                    onChanged: (val) => setState(() => _isDevidenActive = val),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      ScreenDict.getEmergencyCheck(isRpg: isRpg),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      ScreenDict.getEmergencyCheckDesc(isRpg: isRpg),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    value: _isEmergencyActive,
                    onChanged: (val) => setState(
                      () =>
                          !widget.isEmergency ? _isEmergencyActive = val : null,
                    ),
                  ),
                ],

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    UiDict.feeCheck,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    ScreenDict.getFeeCheckDesc(isRpg: isRpg),
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  value: _isFeeActive,
                  onChanged: (val) => setState(() => _isFeeActive = val),
                ),

                if (_isFeeActive) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _feeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: UiDict.feeAmount,
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (_isFeeActive &&
                          (value == null || value.isEmpty || value == '0')) {
                        return UiDict.requiredFee;
                      }
                      return null;
                    },
                    onChanged: (value) => NumberUtils.formatInput(
                      _feeController,
                      value,
                      isDecimal: true,
                      onCalculated: _calculateTotal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  NoteContainer(
                    text: "Note: ${ScreenDict.getFeeCheckDesc(isRpg: isRpg)}",
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],

                if (widget.pendingAllocation == null)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      ScreenDict.getReservedCheck(isRpg: isRpg),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      ScreenDict.getReservedCheckDesc(isRpg: isRpg),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    value: _isReservedActive,
                    onChanged: (val) => setState(() {
                      if (_selectedWallet != null) {
                        _isReservedActive = val;
                      }
                    }),
                  ),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    ScreenDict.roundedCheck,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    ScreenDict.getRoundedCheckDesc(isRpg: isRpg),
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  value: _isRoundedActive,
                  onChanged: (val) {
                    setState(() {
                      _isRoundedActive = val;
                    });
                    _calculateTotal();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool isRpg) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: 24 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.onPrimary.withOpacity(0.2),
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedWallet != null) ...[
            NoteContainer(
              text: widget.pendingAllocation != null
                  ? ScreenDict.getPendingNote(
                      NumberUtils.toIdr(widget.pendingAllocation),
                    )
                  : _isReservedActive
                  ? ScreenDict.getHomeNote(
                      _selectedWallet?.name ?? '',
                      NumberUtils.toIdr(_selectedWallet?.reservedAmount),
                      isRpg: isRpg,
                    )
                  : ScreenDict.getHistoryNote(
                      _selectedWallet?.name ?? '',
                      NumberUtils.toIdr(_selectedWallet?.amount),
                    ),
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ScreenDict.expenseAmount.get(isRpg),
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    NumberUtils.toIdr(_amount, showFull: true),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomButton(
            title: _isNewAssetTab
                ? ScreenDict.investBuyAsset.get(isRpg)
                : ScreenDict.investAddModal.get(isRpg),
            color: colorScheme.primary,
            onTap: _submit,
          ),
        ],
      ),
    );
  }
}
