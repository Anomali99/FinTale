import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../controllers/settings_controller.dart';
import '../../../core/constants/screen_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/utils/enum_types.dart';
import '../../../core/utils/number_utils.dart';
import '../../../models/wallet_model.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_table.dart';

class WalletModal extends StatefulWidget {
  final WalletModel? wallet;
  final bool lock;
  const WalletModal({super.key, this.wallet, this.lock = false});

  @override
  State<WalletModal> createState() => _WalletModalState();
}

class _WalletModalState extends State<WalletModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  late WalletType _selectedType;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.wallet?.name ?? '';
    _selectedType = widget.wallet?.type ?? WalletType.bank;
    NumberUtils.formatInput(
      _amountController,
      widget.wallet?.amount.toString() ?? '0',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final result = WalletModel(
        id: widget.wallet?.id,
        name: _nameController.text.trim(),
        type: _selectedType,
        amount:
            widget.wallet?.amount ??
            NumberUtils.parseToDecimal(_amountController.text),
      );

      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isRpg = context.read<SettingsController>().isRpgMode;
    final colorScheme = Theme.of(context).colorScheme;
    int? decimalDigits = widget.wallet?.type != WalletType.platform ? null : 3;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 24 + bottomInset,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.wallet == null
                  ? ScreenDict.addWallet.get(isRpg)
                  : ScreenDict.updateWallet.get(isRpg),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              enabled: !widget.lock,
              decoration: InputDecoration(
                labelText: ScreenDict.walletName,
                border: const OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? UiDict.requiredName : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<WalletType>(
              initialValue: _selectedType,
              decoration: InputDecoration(
                labelText: ScreenDict.walletType,
                border: OutlineInputBorder(),
              ),
              items: [
                if (widget.lock)
                  DropdownMenuItem(value: WalletType.cash, child: Text('Cash')),
                DropdownMenuItem(value: WalletType.bank, child: Text('Bank')),
                DropdownMenuItem(
                  value: WalletType.eWallet,
                  child: Text('e-Wallet'),
                ),
                DropdownMenuItem(
                  value: WalletType.platform,
                  child: Text('Platform (RDN)'),
                ),
              ],
              onChanged: !widget.lock
                  ? (val) => setState(() => _selectedType = val!)
                  : null,
            ),
            if (widget.wallet == null) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: UiDict.initialAmount,
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) =>
                    NumberUtils.formatInput(_amountController, val),
              ),
            ] else ...[
              const SizedBox(height: 24),
              CustomTable(
                color: colorScheme.surfaceContainerHighest,
                borderColor: colorScheme.primary,
                children: [
                  CustomRowTable(
                    label: ScreenDict.homeTotalBalance.get(false),
                    value: NumberUtils.toIdr(
                      widget.wallet?.amount ?? BigInt.zero,
                      decimalDigits: decimalDigits,
                    ),
                    valueColor: colorScheme.onSurface,
                    boldValue: true,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(
                      color: colorScheme.onSurface.withOpacity(0.1),
                      height: 1,
                    ),
                  ),
                  CustomRowTable(
                    label: ScreenDict.homeRegular.get(isRpg),
                    value: NumberUtils.toIdr(
                      widget.wallet?.regularAmount ?? BigInt.zero,
                      decimalDigits: decimalDigits,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomRowTable(
                    label: ScreenDict.homeSavings.get(isRpg),
                    value: NumberUtils.toIdr(
                      widget.wallet?.reservedAmount ?? BigInt.zero,
                      decimalDigits: decimalDigits,
                    ),
                  ),
                ],
              ),
            ],
            if (!widget.lock) ...[
              const SizedBox(height: 24),
              CustomButton(
                title: widget.wallet == null
                    ? UiDict.addNew
                    : UiDict.saveChanges,
                color: colorScheme.primary,
                onTap: _submit,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
