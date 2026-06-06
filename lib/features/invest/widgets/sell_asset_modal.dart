import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/settings_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/screen_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/utils/enum_types.dart';
import '../../../core/utils/number_utils.dart';
import '../../../models/assets_model.dart';
import '../../../models/transaction_detail_model.dart';
import '../../../models/transaction_model.dart';
import '../../../models/wallet_model.dart';
import '../../../widgets/custom_button.dart';

class SellAssetModal extends StatefulWidget {
  final AssetsModel asset;
  final List<WalletModel> wallets;

  const SellAssetModal({super.key, required this.asset, required this.wallets});

  @override
  State<SellAssetModal> createState() => _SellAssetModalState();
}

class _SellAssetModalState extends State<SellAssetModal> {
  final _formKey = GlobalKey<FormState>();

  final _unitAmountController = TextEditingController();
  final _priceController = TextEditingController();
  final _feeController = TextEditingController(text: '0');

  WalletModel? _selectedWallet;
  bool _isFeeActive = false;
  Decimal _netAmount = Decimal.zero;

  Decimal get _cleanAssetUnit =>
      NumberUtils.parseToDecimal(_unitAmountController.text);
  Decimal get _cleanAssetPrice =>
      NumberUtils.parseToDecimal(_priceController.text);
  Decimal get _cleanFeeAmount =>
      NumberUtils.parseToDecimal(_feeController.text);

  @override
  void dispose() {
    _unitAmountController.dispose();
    _priceController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    Decimal grossAmount = _cleanAssetUnit * _cleanAssetPrice;
    Decimal total = grossAmount;

    if (_isFeeActive) total -= _cleanFeeAmount;

    setState(() {
      _netAmount = total > Decimal.zero ? total : Decimal.zero;
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Decimal unitSold = _cleanAssetUnit;
      Decimal pricePerUnit = _cleanAssetPrice;
      Decimal grossAmount = unitSold * pricePerUnit;
      Decimal feeAmount = _isFeeActive ? _cleanFeeAmount : Decimal.zero;

      double fractionSold = unitSold.toDouble() / widget.asset.unit.toDouble();
      Decimal investedDeduction = Decimal.parse(
        (widget.asset.invested.toDouble() * fractionSold).toStringAsFixed(0),
      );

      Decimal newUnit = widget.asset.unit - unitSold;
      Decimal newInvested = widget.asset.invested - investedDeduction;
      Decimal newValue = newUnit * pricePerUnit;

      if (newUnit <= Decimal.zero) {
        newInvested = Decimal.zero;
        newValue = Decimal.zero;
      }

      AssetsModel updatedAsset = AssetsModel(
        id: widget.asset.id,
        name: widget.asset.name,
        type: widget.asset.type,
        category: widget.asset.category,
        unitName: widget.asset.unitName,
        hasDividend: widget.asset.hasDividend,
        isEmergency: widget.asset.isEmergency,
        invested: newInvested,
        value: newValue,
        unit: newUnit,
      );

      List<TransactionDetailModel> details = [
        TransactionDetailModel(
          title:
              '${widget.asset.name} ${NumberUtils.formatNumber(unitSold)} ${widget.asset.unitName}',
          amount: grossAmount,
          category: TransactionCategory.getTransactionCategory(
            widget.asset.type,
          ),
          flow: FlowType.income,
        ),
      ];

      if (_isFeeActive) {
        details.add(
          TransactionDetailModel(
            title: 'Fee',
            amount: feeAmount,
            category: TransactionCategory.utilities,
            flow: FlowType.expense,
          ),
        );
      }

      TransactionModel transaction = TransactionModel(
        type: TransactionType.income,
        title: ScreenDict.investSellTitle,
        amount: _netAmount,
        status: StatusType.paid,
        walletId: _selectedWallet?.id,
        assetsId: widget.asset.id,
        detailTransaction: details,
        dateTimestamp: DateTime.now().millisecondsSinceEpoch,
      );

      Navigator.pop(context, {
        "asset": updatedAsset,
        "transaction": transaction,
        "emergency_deduction": investedDeduction,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isRpg = context.read<SettingsController>().isRpgMode;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: 24 + bottomInset,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Text(
                ScreenDict.investSellAsset.get(isRpg),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ScreenDict.getClaimTitle(
                  name: widget.asset.name,
                  unit: NumberUtils.formatNumber(widget.asset.unit),
                  unitName: widget.asset.unitName,
                ),
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _unitAmountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: '${UiDict.amount} ${widget.asset.unitName}',
                  border: const OutlineInputBorder(),
                ),

                onChanged: (val) => NumberUtils.formatInput(
                  _unitAmountController,
                  val,
                  isDecimal: true,
                  onCalculated: _calculateTotal,
                ),
                validator: (val) {
                  if (val == null || !NumberUtils.isValidAmount(val)) {
                    return UiDict.requiredAmount;
                  }
                  if (_cleanAssetUnit > widget.asset.unit) {
                    return ScreenDict.investInvalidUnitSell;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: ScreenDict.getInvestPricePerUnit(
                    widget.asset.unitName,
                  ),
                  prefixText: 'Rp ',
                  border: const OutlineInputBorder(),
                ),

                onChanged: (val) => NumberUtils.formatInput(
                  _priceController,
                  val,
                  isDecimal: true,
                  onCalculated: _calculateTotal,
                ),
                validator: (val) =>
                    val == null || !NumberUtils.isValidAmount(val)
                    ? UiDict.requiredPrice
                    : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<WalletModel>(
                initialValue: _selectedWallet,
                decoration: const InputDecoration(
                  labelText: UiDict.destinationWallet,
                  border: OutlineInputBorder(),
                ),
                items: widget.wallets
                    .map((w) => DropdownMenuItem(value: w, child: Text(w.name)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedWallet = val),
                validator: (val) =>
                    val == null ? UiDict.requiredWalletDest : null,
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  UiDict.feeCheck,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  ScreenDict.getFeeCheckDesc(isIncome: true, isRpg: isRpg),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                value: _isFeeActive,
                onChanged: (val) => setState(() {
                  _isFeeActive = val;
                  _calculateTotal();
                }),
              ),

              if (_isFeeActive) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _feeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: UiDict.feeAmount,
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => NumberUtils.formatInput(
                    _feeController,
                    val,
                    isDecimal: true,
                    onCalculated: _calculateTotal,
                  ),
                  validator: (val) =>
                      _isFeeActive &&
                          (val == null || !NumberUtils.isValidAmount(val))
                      ? UiDict.requiredFee
                      : null,
                ),
              ],
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      UiDict.income.get(isRpg),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      NumberUtils.toIdr(_netAmount),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              CustomButton(
                title: ScreenDict.investSell.get(isRpg),
                color: AppColors.primary,
                onTap: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
