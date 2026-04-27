import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/transaction_detail_model.dart';
import '../../../models/transaction_model.dart';
import '../../../models/wallet_model.dart';
import '../../../widgets/custom_button.dart';

class IncomeModal extends StatefulWidget {
  final List<WalletModel> wallets;
  final bool isTransfer;
  const IncomeModal({super.key, required this.wallets, bool? isTransfer})
    : isTransfer = isTransfer ?? false;

  @override
  State<IncomeModal> createState() => _IncomeModalState();
}

class _IncomeModalState extends State<IncomeModal> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController(text: '0');
  final _feeController = TextEditingController(text: '0');

  int? _selectedWallet;
  int? _selectedTarget;
  TransactionCategory? _selectedCategory;
  bool _isFeeActive = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final String cleanAmount = _amountController.text.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );

      BigInt amount = BigInt.parse(cleanAmount.isEmpty ? '0' : cleanAmount);
      int now = DateTime.now().microsecondsSinceEpoch;

      List<TransactionDetailModel> details = [
        TransactionDetailModel(
          title: 'Nominal ${widget.isTransfer ? "Transfer" : "Income"}',
          amount: amount,
          category: widget.isTransfer
              ? TransactionCategory.transfer
              : (_selectedCategory ?? TransactionCategory.business),
          flow: widget.isTransfer ? FlowType.transfer : FlowType.income,
        ),
      ];

      if (_isFeeActive) {
        final String cleanFee = _feeController.text.replaceAll(
          RegExp(r'[^0-9]'),
          '',
        );

        BigInt fee = BigInt.parse(cleanFee.isEmpty ? '0' : cleanFee);
        amount -= fee;
        details.add(
          TransactionDetailModel(
            title: 'Fee',
            amount: fee,
            category: TransactionCategory.utilities,
            flow: FlowType.expense,
          ),
        );
      }

      final result = TransactionModel(
        type: widget.isTransfer
            ? TransactionType.transfer
            : TransactionType.income,
        title: _titleController.text.trim(),
        amount: amount,
        status: StatusType.paid,
        walletId: _selectedWallet,
        targetId: _selectedTarget,
        dateTimestamp: now,
        detailTransaction: details,
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isTransfer ? 'Transfer Balance' : 'Add New Income',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g. Monthly Salary, Freelance Project...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                initialValue: _selectedWallet,
                decoration: InputDecoration(
                  labelText: '${widget.isTransfer ? "From" : "Target"} Wallet',
                  border: OutlineInputBorder(),
                ),
                items: widget.wallets.map((wallet) {
                  return DropdownMenuItem(
                    value: wallet.id,
                    child: Text(wallet.name),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedWallet = val),
              ),
              const SizedBox(height: 16),

              if (widget.isTransfer) ...[
                DropdownButtonFormField<int>(
                  initialValue: _selectedTarget,
                  decoration: const InputDecoration(
                    labelText: 'To Wallet',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.wallets
                      .where((e) => e.id != _selectedWallet)
                      .map((wallet) {
                        return DropdownMenuItem(
                          value: wallet.id,
                          child: Text(wallet.name),
                        );
                      })
                      .toList(),
                  onChanged: (val) => setState(() => _selectedTarget = val),
                ),
                const SizedBox(height: 16),
              ],

              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText:
                      '${widget.isTransfer ? "Transfer" : "Income"} Amount',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              if (!widget.isTransfer) ...[
                DropdownButtonFormField<TransactionCategory>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: TransactionCategory.business,
                      child: Text('Business & Bonus'),
                    ),
                    DropdownMenuItem(
                      value: TransactionCategory.salary,
                      child: Text('Salary & Wage'),
                    ),
                  ],
                  onChanged: (val) => setState(() => _selectedCategory = val),
                ),
                const SizedBox(height: 16),
              ],

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Has Admin Fee?'),
                subtitle: const Text(
                  'Check this if the income has a deduction fee',
                ),
                value: _isFeeActive,
                onChanged: (val) => setState(() => _isFeeActive = val),
              ),

              if (_isFeeActive) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _feeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Fee Amount',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: Colors.blue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Note: If the fee is active, the income amount will be reduced by the fee before being added to your wallet.',
                          style: TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              CustomButton(
                title: widget.isTransfer ? 'Transfer' : 'Add Income',
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
