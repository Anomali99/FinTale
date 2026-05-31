import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/screen_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/utils/enum_types.dart';
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

  String _formatNumber(BigInt value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String _cleanNumber(String value) {
    return value.replaceAll('.', '');
  }

  void _onPerUnitChanged(String value) {
    String cleanText = _cleanNumber(value);

    if (cleanText.isEmpty) {
      _perUnitController.text = '';
      _totalController.text = '';
      return;
    }

    BigInt perUnit = BigInt.tryParse(cleanText) ?? BigInt.zero;
    _perUnitController.value = TextEditingValue(
      text: _formatNumber(perUnit),
      selection: TextSelection.collapsed(offset: _formatNumber(perUnit).length),
    );

    Decimal unitAset = widget.asset.unit;
    BigInt total = BigInt.from(
      (perUnit.toDouble() * unitAset.toDouble()).round(),
    );
    _totalController.text = _formatNumber(total);
  }

  void _onTotalChanged(String value) {
    String cleanText = _cleanNumber(value);

    if (cleanText.isEmpty) {
      _totalController.text = '';
      _perUnitController.text = '';
      return;
    }

    BigInt total = BigInt.tryParse(cleanText) ?? BigInt.zero;
    _totalController.value = TextEditingValue(
      text: _formatNumber(total),
      selection: TextSelection.collapsed(offset: _formatNumber(total).length),
    );

    Decimal unitAset = widget.asset.unit;
    if (unitAset > Decimal.zero) {
      BigInt perUnit = BigInt.from(
        (total.toDouble() / unitAset.toDouble()).round(),
      );

      _perUnitController.text = _formatNumber(perUnit);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      BigInt totalAmount = BigInt.parse(_cleanNumber(_totalController.text));

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
                ScreenDict.investClaimDeviden,
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
                controller: _perUnitController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: ScreenDict.getInvestDevidenPerUnit(
                    widget.asset.unitName,
                  ),
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                onChanged: _onPerUnitChanged,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _totalController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: ScreenDict.investTotalDeviden,
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                onChanged: _onTotalChanged,
                validator: (val) => val == null || val.isEmpty
                    ? ScreenDict.investTotalDevidenRequired
                    : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<WalletModel>(
                initialValue: _selectedWallet,
                decoration: InputDecoration(
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

              NoteContainer(
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
