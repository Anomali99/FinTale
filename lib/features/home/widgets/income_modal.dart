import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/category_dict.dart';
import '../../../core/constants/home_dict.dart';
import '../../../core/constants/shared_dict.dart';
import '../../../core/constants/skill_dict.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/transaction_detail_model.dart';
import '../../../models/transaction_model.dart';
import '../../../models/wallet_model.dart';
import '../../../widgets/custom_button.dart';

class IncomeModal extends StatefulWidget {
  final List<WalletModel> wallets;
  final Map<Enum, double>? allocation;
  final bool isTransfer;
  const IncomeModal({
    super.key,
    required this.wallets,
    this.allocation,
    bool? isTransfer,
  }) : isTransfer = isTransfer ?? false;

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
  bool _isAllocationActive = false;
  bool _isReservedActive = false;

  BigInt get _cleanAmount => BigInt.parse(
    _amountController.text.replaceAll('.', '').isEmpty
        ? '0'
        : _amountController.text.replaceAll('.', ''),
  );

  BigInt get _cleanFeeAmount => BigInt.parse(
    _feeController.text.replaceAll('.', '').isEmpty
        ? '0'
        : _feeController.text.replaceAll('.', ''),
  );

  double get _onePercentageAmount {
    double amount = _cleanAmount.toDouble();
    if (_isFeeActive) {
      amount -= _cleanFeeAmount.toDouble();
    }
    return amount / 100;
  }

  BigInt get _reservedAmount {
    WalletModel? wallet = widget.wallets.firstWhere(
      (e) => e.id == _selectedWallet,
    );
    return wallet.reservedAmount;
  }

  String get _reservedName {
    WalletModel? wallet = widget.wallets.firstWhere(
      (e) => e.id == _selectedWallet,
    );
    return wallet.name;
  }

  BigInt? get _maxAmount {
    if (_isReservedActive) return _reservedAmount;

    if (widget.isTransfer && _selectedWallet != null) {
      WalletModel? wallet = widget.wallets.firstWhere(
        (e) => e.id == _selectedWallet,
      );
      return wallet.amount;
    }

    return null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      BigInt amount = _cleanAmount;
      int now = DateTime.now().millisecondsSinceEpoch;

      List<TransactionDetailModel> details = [
        TransactionDetailModel(
          title: 'Nominal ${widget.isTransfer ? "Transfer" : "Income"}',
          amount: _cleanAmount,
          category: widget.isTransfer
              ? TransactionCategory.transfer
              : (_selectedCategory ?? TransactionCategory.business),
          flow: widget.isTransfer ? FlowType.transfer : FlowType.income,
        ),
      ];

      if (_isFeeActive) {
        amount -= _cleanFeeAmount;
        details.add(
          TransactionDetailModel(
            title: 'Fee',
            amount: _cleanFeeAmount,
            category: TransactionCategory.utilities,
            flow: FlowType.expense,
          ),
        );
      }

      final transaction = TransactionModel(
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

      Navigator.pop(context, {
        "transaction": transaction,
        "auto_allocation": _isAllocationActive,
        "use_reserved": _isReservedActive,
      });
    }
  }

  void _onChanged(
    TextEditingController controller,
    String value, {
    BigInt? max,
    BigInt? min,
  }) {
    String cleanText = value.replaceAll('.', '');

    if (cleanText.isEmpty) {
      controller.text = '';
      return;
    }

    BigInt currentValue = BigInt.tryParse(cleanText) ?? BigInt.zero;

    if (max != null && currentValue > max) {
      currentValue = max;
    }

    if (min != null && currentValue < min) {
      currentValue = min;
    } else if (currentValue < BigInt.zero) {
      currentValue = BigInt.zero;
    }

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
                widget.isTransfer
                    ? HomeDict.newTransfer
                    : HomeDict.recordIncome,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: SharedDict.title,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return SharedDict.requiredTitle;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                initialValue: _selectedWallet,
                decoration: InputDecoration(
                  labelText: widget.isTransfer
                      ? HomeDict.transferFrom
                      : HomeDict.targetWallet,
                  border: OutlineInputBorder(),
                ),
                items: widget.wallets.map((wallet) {
                  return DropdownMenuItem(
                    value: wallet.id,
                    child: Text(wallet.name),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value == 0) {
                    return SharedDict.requiredWallet;
                  }
                  return null;
                },
                onChanged: (val) {
                  if (_selectedTarget == val) _selectedTarget = null;
                  setState(() => _selectedWallet = val);
                  _onChanged(
                    _amountController,
                    _amountController.text,
                    max: _maxAmount,
                  );
                  _onChanged(
                    _feeController,
                    _feeController.text,
                    max: _cleanAmount,
                  );
                },
              ),
              const SizedBox(height: 16),

              if (widget.isTransfer) ...[
                DropdownButtonFormField<int>(
                  initialValue: _selectedTarget,
                  decoration: InputDecoration(
                    labelText: HomeDict.transferTo,
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
                  validator: (value) {
                    if (widget.isTransfer && (value == null || value == 0)) {
                      return SharedDict.requiredWalletDest;
                    }
                    return null;
                  },
                  onChanged: (val) => setState(() => _selectedTarget = val),
                ),
                const SizedBox(height: 16),
              ],

              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText:
                      '${SharedDict.amount} ${widget.isTransfer ? SharedDict.transfer.get(false) : SharedDict.income.get(false)}',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || value == '0') {
                    return SharedDict.requiredAmount;
                  }
                  return null;
                },
                onChanged: (value) {
                  _onChanged(_amountController, value, max: _maxAmount);
                  _onChanged(
                    _feeController,
                    _feeController.text,
                    max: _cleanAmount,
                  );
                },
              ),
              const SizedBox(height: 16),

              if (!widget.isTransfer) ...[
                DropdownButtonFormField<TransactionCategory>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: SharedDict.category,
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: TransactionCategory.business,
                      child: Text(CategoryDict.business.get(false)),
                    ),
                    DropdownMenuItem(
                      value: TransactionCategory.salary,
                      child: Text(CategoryDict.salary.get(false)),
                    ),
                  ],
                  validator: (value) {
                    if (value == null && !widget.isTransfer) {
                      return SharedDict.requiredCategory;
                    }
                    return null;
                  },
                  onChanged: (val) => setState(() => _selectedCategory = val),
                ),
                const SizedBox(height: 16),
              ],

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(HomeDict.feeCheck),
                subtitle: const Text(HomeDict.feeCheckDesc),
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
                    labelText: HomeDict.feeAmount,
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_isFeeActive &&
                        (value == null || value.isEmpty || value == '0')) {
                      return HomeDict.requiredFee;
                    }
                    return null;
                  },
                  onChanged: (value) =>
                      _onChanged(_feeController, value, max: _cleanAmount),
                ),
                const SizedBox(height: 12),
                _buildNoteContainer(HomeDict.feeDesc),
              ],

              const SizedBox(height: 12),

              if (widget.isTransfer) ...[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(HomeDict.reservedCheck),
                  subtitle: Text(HomeDict.reservedCheckDesc),
                  value: _isReservedActive,
                  onChanged: (val) => setState(() {
                    if (_selectedWallet != null) {
                      _isReservedActive = val;
                      _onChanged(
                        _amountController,
                        _amountController.text,
                        max: _reservedAmount,
                      );
                      _onChanged(
                        _feeController,
                        _feeController.text,
                        max: _cleanAmount,
                      );
                    }
                  }),
                ),

                if (_isReservedActive) ...[
                  const SizedBox(height: 12),
                  _buildNoteContainer(
                    '${HomeDict.reservedDesc} $_reservedName: ${CurrencyFormatter.convertToIdr(_reservedAmount)}.',
                  ),
                ],
              ] else ...[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(HomeDict.autoCheck),
                  subtitle: Text(HomeDict.autoCheckDesc),
                  value: _isAllocationActive,
                  onChanged: (val) => setState(() => _isAllocationActive = val),
                ),

                if (_isAllocationActive) ...[
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          HomeDict.breakdown,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Colors.white24),
                        const SizedBox(height: 12),

                        if (widget.allocation != null) ...[
                          ...widget.allocation!.entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: _buildAllocationRow(
                                entry.key,
                                entry.value,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],

              const SizedBox(height: 32),

              CustomButton(
                title: widget.isTransfer
                    ? SharedDict.transfer.get(false)
                    : HomeDict.addIncome,
                color: AppColors.primary,
                onTap: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteContainer(String note, {Color color = Colors.blue}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Note: $note',
              style: TextStyle(fontSize: 12, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllocationRow(Enum name, double percentage) {
    double amount = _onePercentageAmount * percentage;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            SkillDict.getByEnum(name).get(false),
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),

        Expanded(
          flex: 1,
          child: Text(
            "${percentage.toInt().toString()}%",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        Expanded(
          flex: 2,
          child: Text(
            CurrencyFormatter.convertToIdr(amount),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
