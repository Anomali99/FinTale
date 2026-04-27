import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
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
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late WalletType _selectedType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.wallet?.name ?? '');
    _amountController = TextEditingController(
      text: widget.wallet?.amount.toString() ?? '0',
    );
    _selectedType = widget.wallet?.type ?? WalletType.bank;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final String cleanAmount = _amountController.text.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );

      final result = WalletModel(
        id: widget.wallet?.id,
        name: _nameController.text.trim(),
        type: _selectedType,
        amount: BigInt.parse(cleanAmount.isEmpty ? '0' : cleanAmount),
      );

      Navigator.pop(context, result);
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
              widget.wallet == null ? 'Add New Wallet' : 'Update Wallet',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Wallet Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<WalletType>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type',
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              title: widget.wallet == null ? 'Add' : 'Save',
              color: AppColors.primary,
              onTap: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
