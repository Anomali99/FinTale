import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/home_dict.dart';
import '../../../core/constants/shared_dict.dart';
import '../../../models/wallet_model.dart';
import '../../../widgets/custom_button.dart';

class WalletModal extends StatefulWidget {
  final WalletModel? wallet;
  const WalletModal({super.key, this.wallet});

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
    _onChanged(widget.wallet?.amount.toString() ?? '0');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final String cleanAmount = _amountController.text.replaceAll('.', '');

      final result = WalletModel(
        id: widget.wallet?.id,
        name: _nameController.text.trim(),
        type: _selectedType,
        amount:
            widget.wallet?.amount ??
            BigInt.parse(cleanAmount.isEmpty ? '0' : cleanAmount),
      );

      Navigator.pop(context, result);
    }
  }

  void _onChanged(String value) {
    String cleanText = value.replaceAll('.', '');

    if (cleanText.isEmpty) {
      _amountController.text = '';
      return;
    }

    BigInt currentValue = BigInt.tryParse(cleanText) ?? BigInt.zero;

    String formattedText = currentValue.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );

    if (_amountController.text != formattedText) {
      _amountController.value = TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 24 + bottomInset,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
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
                  ? HomeDict.addWallet
                  : HomeDict.updateWallet,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: HomeDict.walletName,
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.isEmpty
                  ? SharedDict.requiredName
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<WalletType>(
              initialValue: _selectedType,
              decoration: InputDecoration(
                labelText: HomeDict.walletType,
                border: OutlineInputBorder(),
              ),
              items: [
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
              onChanged: (val) => setState(() => _selectedType = val!),
            ),
            if (widget.wallet == null) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: HomeDict.initialAmount,
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                onChanged: _onChanged,
              ),
            ],
            const SizedBox(height: 24),
            CustomButton(
              title: widget.wallet == null
                  ? SharedDict.addNew
                  : SharedDict.saveChanges,
              color: AppColors.primary,
              onTap: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
