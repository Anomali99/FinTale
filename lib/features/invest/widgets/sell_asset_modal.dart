import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../controllers/settings_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/screen_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/enum_types.dart';
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
  BigInt _netAmount = BigInt.zero;

  Decimal get _cleanAssetUnit => _unitAmountController.text.isNotEmpty
      ? Decimal.parse(_unitAmountController.text.replaceAll(',', '.'))
      : Decimal.zero;

  BigInt get _cleanAssetPriceUnit => _priceController.text.isNotEmpty
      ? BigInt.parse(_priceController.text.replaceAll('.', ''))
      : BigInt.zero;

  BigInt get _cleanFeeAmount => _feeController.text.isNotEmpty
      ? BigInt.parse(_feeController.text.replaceAll('.', ''))
      : BigInt.zero;

  @override
  void dispose() {
    _unitAmountController.dispose();
    _priceController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  void _onNumberChanged(
    TextEditingController controller,
    String value, {
    bool isDecimal = false,
  }) {
    String cleanText = isDecimal
        ? value.replaceAll(',', '.')
        : value.replaceAll('.', '');

    if (cleanText.isEmpty) {
      controller.text = '';
      _calculateTotal();
      return;
    }

    if (!isDecimal) {
      BigInt currentValue = BigInt.tryParse(cleanText) ?? BigInt.zero;
      String formattedText = currentValue.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );

      if (controller.text != formattedText) {
        controller.value = TextEditingValue(
          text: formattedText,
          selection: TextSelection.collapsed(offset: formattedText.length),
        );
      }
    }
    _calculateTotal();
  }

  void _calculateTotal() {
    try {
      BigInt grossAmount = BigInt.from(
        (_cleanAssetUnit.toDouble() * _cleanAssetPriceUnit.toDouble()).round(),
      );
      BigInt total = grossAmount;

      if (_isFeeActive) {
        total -= _cleanFeeAmount;
      }

      setState(() {
        _netAmount = total > BigInt.zero ? total : BigInt.zero;
      });
    } catch (e) {
      _netAmount = BigInt.zero;
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Decimal unitSold = _cleanAssetUnit;

      if (unitSold > widget.asset.unit) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(ScreenDict.investInvalidUnitSell)),
        );
        return;
      }

      BigInt pricePerUnit = _cleanAssetPriceUnit;
      BigInt grossAmount = BigInt.from(
        (unitSold.toDouble() * pricePerUnit.toDouble()).round(),
      );
      BigInt feeAmount = _isFeeActive ? _cleanFeeAmount : BigInt.zero;

      double fractionSold = unitSold.toDouble() / widget.asset.unit.toDouble();
      BigInt investedDeduction = BigInt.from(
        (widget.asset.invested.toDouble() * fractionSold).round(),
      );

      Decimal newUnit = widget.asset.unit - unitSold;
      BigInt newInvested = widget.asset.invested - investedDeduction;
      BigInt newValue = BigInt.from(
        (newUnit.toDouble() * pricePerUnit.toDouble()).round(),
      );

      if (newUnit <= Decimal.zero) {
        newInvested = BigInt.zero;
        newValue = BigInt.zero;
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
          title: '${widget.asset.name} $unitSold ${widget.asset.unitName}',
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                ScreenDict.getClaimTitle(
                  name: widget.asset.name,
                  unit: widget.asset.unit.toString(),
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
                onChanged: (val) => _onNumberChanged(
                  _unitAmountController,
                  val,
                  isDecimal: true,
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return UiDict.requiredAmount;

                  try {
                    Decimal enteredUnit = Decimal.parse(
                      val.replaceAll(',', '.'),
                    );
                    if (enteredUnit > widget.asset.unit) {
                      return ScreenDict.investInvalidUnitSell;
                    }
                  } catch (e) {
                    return UiDict.requiredAmount;
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: ScreenDict.getInvestPricePerUnit(
                    widget.asset.unitName,
                  ),
                  prefixText: 'Rp ',
                  border: const OutlineInputBorder(),
                ),
                onChanged: (val) =>
                    _onNumberChanged(_priceController, val, isDecimal: false),
                validator: (val) =>
                    val == null || val.isEmpty ? UiDict.requiredPrice : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<WalletModel>(
                initialValue: _selectedWallet,
                decoration: const InputDecoration(
                  labelText: UiDict.destinationWallet,
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
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                value: _isFeeActive,
                onChanged: (val) {
                  setState(() {
                    _isFeeActive = val;
                    _calculateTotal();
                  });
                },
              ),

              if (_isFeeActive) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _feeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
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
                  onChanged: (value) => _onNumberChanged(_feeController, value),
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
                      CurrencyFormatter.convertToIdr(_netAmount),
                      style: GoogleFonts.poppins(
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
