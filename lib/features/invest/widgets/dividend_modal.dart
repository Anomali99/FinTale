import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/screen_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/enum_types.dart';
import '../../../core/utils/number_utils.dart';
import '../../../models/assets_model.dart';
import '../../../models/transaction_detail_model.dart';
import '../../../models/transaction_model.dart';
import '../../../models/wallet_model.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/note_container.dart';

class DividendModal extends StatefulWidget {
  final AssetsModel asset;
  final List<WalletModel> wallets;

  const DividendModal({super.key, required this.asset, required this.wallets});

  @override
  State<DividendModal> createState() => _DividendModalState();
}

class _DividendModalState extends State<DividendModal> {
  final _formKey = GlobalKey<FormState>();

  final _perUnitController = TextEditingController();
  final _totalController = TextEditingController();
  WalletModel? _selectedWallet;

  @override
  void dispose() {
    _perUnitController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  void _calculateTotalFromPerUnit() {
    Decimal perUnit = NumberUtils.parseToDecimal(_perUnitController.text);
    if (perUnit > Decimal.zero) {
      Decimal total = perUnit * widget.asset.unit;
      _totalController.text = NumberUtils.formatNumber(total, decimalDigits: 0);
    } else {
      _totalController.text = '';
    }
  }

  void _calculatePerUnitFromTotal() {
    Decimal total = NumberUtils.parseToDecimal(_totalController.text);
    if (total > Decimal.zero && widget.asset.unit > Decimal.zero) {
      double perUnit = total.toDouble() / widget.asset.unit.toDouble();
      _perUnitController.text = NumberUtils.formatNumber(
        perUnit,
        decimalDigits: 0,
      );
    } else {
      _perUnitController.text = '';
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Decimal totalAmount = NumberUtils.parseToDecimal(_totalController.text);

      TransactionModel transaction = TransactionModel(
        type: TransactionType.income,
        title: ScreenDict.investClaimDeviden,
        amount: totalAmount,
        status: StatusType.paid,
        walletId: _selectedWallet?.id,
        assetsId: widget.asset.id,
        detailTransaction: [
          TransactionDetailModel(
            title: '${ScreenDict.investClaim} ${widget.asset.name}',
            amount: totalAmount,
            category: TransactionCategory.dividend,
            flow: FlowType.income,
          ),
        ],
        dateTimestamp: DateTime.now().millisecondsSinceEpoch,
      );

      Navigator.pop(context, transaction);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: 24 + bottomInset,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
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
                ScreenDict.investClaimDeviden,
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
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _perUnitController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: ScreenDict.getInvestDevidenPerUnit(
                    widget.asset.unitName,
                  ),
                  prefixText: 'Rp ',
                  border: const OutlineInputBorder(),
                ),

                onChanged: (val) => NumberUtils.formatInput(
                  _perUnitController,
                  val,
                  isDecimal: true,
                  onCalculated: _calculateTotalFromPerUnit,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _totalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: ScreenDict.investTotalDeviden,
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),

                onChanged: (val) => NumberUtils.formatInput(
                  _totalController,
                  val,
                  isDecimal: true,
                  onCalculated: _calculatePerUnitFromTotal,
                ),
                validator: (val) =>
                    val == null || !NumberUtils.isValidAmount(val)
                    ? ScreenDict.investTotalDevidenRequired
                    : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<WalletModel>(
                initialValue: _selectedWallet,
                decoration: const InputDecoration(
                  labelText: UiDict.destinationWallet,
                  border: OutlineInputBorder(),
                ),
                items: widget.wallets.map((wallet) {
                  return DropdownMenuItem(
                    value: wallet,
                    child: Text(wallet.name),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedWallet = val),
                validator: (val) =>
                    val == null ? UiDict.requiredWalletDest : null,
              ),
              const SizedBox(height: 16),

              const NoteContainer(
                text: ScreenDict.investDevidenDesc,
                color: Colors.grey,
              ),
              const SizedBox(height: 32),

              CustomButton(
                title: ScreenDict.investClaim,
                color: AppColors.success,
                onTap: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
