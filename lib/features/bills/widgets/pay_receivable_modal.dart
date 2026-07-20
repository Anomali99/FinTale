import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/screen_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/number_utils.dart';
import '../../../models/wallet_model.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_date_time_picker.dart';
import '../../../widgets/note_container.dart';

class PayReceivableModal extends StatefulWidget {
  final List<WalletModel> wallets;
  final String title;
  final bool isRpg;
  const PayReceivableModal({
    super.key,
    required this.wallets,
    required this.title,
    this.isRpg = false,
  });

  @override
  State<PayReceivableModal> createState() => _PayReceivableModalState();
}

class _PayReceivableModalState extends State<PayReceivableModal> {
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController(text: '0');
  final _feeController = TextEditingController(text: '0');

  DateTime _selectedDate = DateTime.now();
  WalletModel? _selectedWallet;
  bool _isFeeActive = false;

  Decimal get _cleanAmount =>
      NumberUtils.parseToDecimal(_amountController.text);

  Decimal get _cleanFee => NumberUtils.parseToDecimal(_feeController.text);

  @override
  void dispose() {
    _amountController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        "amount": _cleanAmount,
        "fee": _isFeeActive ? _cleanFee : null,
        "wallet_id": _selectedWallet?.id,
        "datetime": _selectedDate.millisecondsSinceEpoch,
      });
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
                    color: colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: UiDict.amount,
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || value == '0') {
                    return UiDict.requiredAmount;
                  }
                  return null;
                },
                onChanged: (val) =>
                    NumberUtils.formatInput(_amountController, val),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<WalletModel>(
                initialValue: _selectedWallet,
                decoration: InputDecoration(
                  labelText: UiDict.saveTo,
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

              CustomDateTimePicker(
                initialDate: _selectedDate,
                label: ScreenDict.historyTime.get(widget.isRpg),
                onChanged: (newDate) {
                  setState(() {
                    _selectedDate = newDate;
                  });
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  UiDict.feeCheck,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  ScreenDict.getFeeCheckDesc(isRpg: widget.isRpg),
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
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: UiDict.feeAmount,
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) =>
                      NumberUtils.formatInput(_feeController, val),
                  validator: (val) {
                    if (_isFeeActive &&
                        (val == null || !NumberUtils.isValidAmount(val))) {
                      return UiDict.requiredFee;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                NoteContainer(
                  text:
                      "Note: ${ScreenDict.getFeeCheckDesc(isIncome: true, isRpg: widget.isRpg)}",
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ScreenDict.getHomeIncome(
                            _selectedWallet?.name ?? '',
                            isExpense: false,
                            isRpg: widget.isRpg,
                          ),
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                        Text(
                          NumberUtils.toIdr(_cleanAmount - _cleanFee),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.getSuccess(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                title: ScreenDict.receivableApply.get(widget.isRpg),
                color: AppColors.getSuccess(context),
                onTap: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
