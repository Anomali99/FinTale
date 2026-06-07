import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../controllers/settings_controller.dart';
import '../../../core/constants/category_dict.dart';
import '../../../core/constants/gamification_dict.dart';
import '../../../core/constants/screen_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/enum_types.dart';
import '../../../core/utils/number_utils.dart';
import '../../../models/transaction_detail_model.dart';
import '../../../models/transaction_model.dart';
import '../../../models/wallet_model.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/note_container.dart';

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

  WalletModel? _selectedWallet;
  WalletModel? _selectedTarget;
  TransactionCategory? _selectedCategory;
  bool _isFeeActive = false;
  bool _isAllocationActive = false;
  bool _isReservedActive = false;

  double get _onePercentageAmount {
    double amount = NumberUtils.parseToDecimal(
      _amountController.text,
    ).toDouble();
    if (_isFeeActive) {
      amount -= NumberUtils.parseToDecimal(_feeController.text).toDouble();
    }
    return amount / 100;
  }

  Decimal? get _maxAmount {
    if (_isReservedActive) return _selectedWallet?.reservedAmount;

    if (widget.isTransfer && _selectedWallet != null) {
      return _selectedWallet?.amount;
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
      Decimal amount = NumberUtils.parseToDecimal(_amountController.text);
      int now = DateTime.now().millisecondsSinceEpoch;

      List<TransactionDetailModel> details = [
        TransactionDetailModel(
          title: widget.isTransfer
              ? UiDict.getNominal(UiDict.transfer.get(false))
              : UiDict.getNominal(UiDict.income.get(false)),
          amount: NumberUtils.parseToDecimal(_amountController.text),
          category: widget.isTransfer
              ? TransactionCategory.transfer
              : (_selectedCategory ?? TransactionCategory.business),
          flow: widget.isTransfer ? FlowType.transfer : FlowType.income,
        ),
      ];

      if (_isFeeActive) {
        amount -= NumberUtils.parseToDecimal(_feeController.text);
        details.add(
          TransactionDetailModel(
            title: 'Fee',
            amount: NumberUtils.parseToDecimal(_feeController.text),
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
        walletId: _selectedWallet?.id ?? 0,
        targetId: _selectedTarget?.id,
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
    Decimal? max,
    Decimal? min,
  }) {
    Decimal currentValue = NumberUtils.parseToDecimal(value);

    if (max != null && currentValue > max) {
      currentValue = max;
    }

    if (min != null && currentValue < min) {
      currentValue = min;
    } else if (currentValue < Decimal.zero) {
      currentValue = Decimal.zero;
    }

    NumberUtils.formatInput(controller, currentValue.toString());
  }

  @override
  Widget build(BuildContext context) {
    final isRpg = context.read<SettingsController>().isRpgMode;
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
                    ? ScreenDict.newTranfer.get(isRpg)
                    : ScreenDict.recordIncome.get(isRpg),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: UiDict.title,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return UiDict.requiredTitle;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<WalletModel>(
                initialValue: _selectedWallet,
                decoration: InputDecoration(
                  labelText: widget.isTransfer
                      ? UiDict.originWallet
                      : UiDict.saveTo,
                  border: OutlineInputBorder(),
                ),
                items: widget.wallets.map((wallet) {
                  return DropdownMenuItem(
                    value: wallet,
                    child: Text(wallet.name),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value == 0) {
                    return UiDict.requiredWallet;
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
                    max: NumberUtils.parseToDecimal(_amountController.text),
                  );
                },
              ),
              const SizedBox(height: 16),

              if (widget.isTransfer) ...[
                DropdownButtonFormField<WalletModel>(
                  initialValue: _selectedTarget,
                  decoration: InputDecoration(
                    labelText: UiDict.destinationWallet,
                    border: OutlineInputBorder(),
                  ),
                  items: widget.wallets
                      .where((e) => e.id != _selectedWallet)
                      .map((wallet) {
                        return DropdownMenuItem(
                          value: wallet,
                          child: Text(wallet.name),
                        );
                      })
                      .toList(),
                  validator: (value) {
                    if (widget.isTransfer && (value == null || value == 0)) {
                      return UiDict.requiredWalletDest;
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
                      '${UiDict.amount} ${widget.isTransfer ? UiDict.transfer.get(false) : UiDict.income.get(false)}',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || value == '0') {
                    return UiDict.requiredAmount;
                  }
                  return null;
                },
                onChanged: (value) {
                  _onChanged(_amountController, value, max: _maxAmount);
                  _onChanged(
                    _feeController,
                    _feeController.text,
                    max: NumberUtils.parseToDecimal(_amountController.text),
                  );
                },
              ),
              const SizedBox(height: 16),

              if (!widget.isTransfer) ...[
                DropdownButtonFormField<TransactionCategory>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: UiDict.category,
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
                      return UiDict.requiredCategory;
                    }
                    return null;
                  },
                  onChanged: (val) => setState(() => _selectedCategory = val),
                ),
                const SizedBox(height: 16),
              ],

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  UiDict.feeCheck,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  ScreenDict.getFeeCheckDesc(
                    isIncome: !widget.isTransfer,
                    isRpg: isRpg,
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
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
                  validator: (value) {
                    if (_isFeeActive &&
                        (value == null || value.isEmpty || value == '0')) {
                      return UiDict.requiredFee;
                    }
                    return null;
                  },
                  onChanged: (value) => _onChanged(
                    _feeController,
                    value,
                    max: NumberUtils.parseToDecimal(_amountController.text),
                  ),
                ),
                const SizedBox(height: 12),
                NoteContainer(
                  text:
                      "Note: ${ScreenDict.getFeeCheckDesc(isIncome: !widget.isTransfer, isRpg: isRpg)}",
                  color: Colors.grey,
                ),
              ],

              const SizedBox(height: 12),

              if (widget.isTransfer) ...[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    ScreenDict.getReservedCheck(isRpg: isRpg),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    ScreenDict.getReservedCheckDesc(isRpg: isRpg),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  value: _isReservedActive,
                  onChanged: (val) => setState(() {
                    if (_selectedWallet != null) {
                      _isReservedActive = val;
                      _onChanged(
                        _amountController,
                        _amountController.text,
                        max: _selectedWallet?.reservedAmount,
                      );
                      _onChanged(
                        _feeController,
                        _feeController.text,
                        max: NumberUtils.parseToDecimal(_amountController.text),
                      );
                    }
                  }),
                ),
              ] else ...[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    UiDict.autoCheck,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    UiDict.autoCheckDesc,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
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
                          ScreenDict.homeBreakdown.get(isRpg),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Colors.white24),
                        const SizedBox(height: 12),

                        if (widget.allocation != null &&
                            !widget.isTransfer) ...[
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

              const SizedBox(height: 16),
              if (_selectedWallet != null) ...[
                NoteContainer(
                  text: _isReservedActive
                      ? ScreenDict.getHomeNote(
                          _selectedWallet?.name ?? '',
                          NumberUtils.toIdr(_selectedWallet?.reservedAmount),
                          isRpg: isRpg,
                        )
                      : ScreenDict.getHistoryNote(
                          _selectedWallet?.name ?? '',
                          NumberUtils.toIdr(_selectedWallet?.amount),
                        ),
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
              ],

              CustomButton(
                title: widget.isTransfer
                    ? UiDict.transfer.get(isRpg)
                    : ScreenDict.saveIncome.get(isRpg),
                color: AppColors.primary,
                onTap: _submit,
              ),
            ],
          ),
        ),
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
            GamificationDict.getSkillByEnum(name).get(false),
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
            NumberUtils.toIdr(amount),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
