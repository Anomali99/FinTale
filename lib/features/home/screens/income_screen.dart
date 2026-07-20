import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../controllers/settings_controller.dart';
import '../../../controllers/wallet_controller.dart';
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
import '../../../widgets/custom_date_time_picker.dart';
import '../../../widgets/note_container.dart';

class IncomeScreen extends StatefulWidget {
  final Map<Enum, double>? allocation;
  final bool isTransfer;
  const IncomeScreen({super.key, this.allocation, bool? isTransfer})
    : isTransfer = isTransfer ?? false;

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController(text: '0');
  final _feeController = TextEditingController(text: '0');

  DateTime _selectedDate = DateTime.now();
  WalletModel? _selectedWallet;
  WalletModel? _selectedTarget;
  TransactionCategory? _selectedCategory;
  bool _isFeeActive = false;
  bool _isAllocationActive = false;
  bool _isReservedActive = false;

  Decimal get _cleanAmount =>
      NumberUtils.parseToDecimal(_amountController.text);

  Decimal get _cleanFee => NumberUtils.parseToDecimal(_feeController.text);

  double get _onePercentageAmount {
    double amount = _cleanAmount.toDouble();
    if (_isFeeActive) {
      amount -= _cleanFee.toDouble();
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
      Decimal amount = _cleanAmount;

      List<TransactionDetailModel> details = [
        TransactionDetailModel(
          title: widget.isTransfer
              ? UiDict.getNominal(UiDict.transfer.get(false))
              : UiDict.getNominal(UiDict.income.get(false)),
          amount: _cleanAmount,
          category: widget.isTransfer
              ? TransactionCategory.transfer
              : (_selectedCategory ?? TransactionCategory.business),
          flow: widget.isTransfer ? FlowType.transfer : FlowType.income,
        ),
      ];

      if (_isFeeActive) {
        amount -= _cleanFee;
        details.add(
          TransactionDetailModel(
            title: 'Fee',
            amount: _cleanFee,
            category: TransactionCategory.utilities,
            flow: FlowType.expense,
          ),
        );
      }

      TransactionModel transaction = TransactionModel(
        type: widget.isTransfer
            ? TransactionType.transfer
            : TransactionType.income,
        title: _titleController.text.trim(),
        amount: amount,
        status: StatusType.paid,
        walletId: _selectedWallet?.id ?? 0,
        targetId: _selectedTarget?.id,
        dateTimestamp: _selectedDate.millisecondsSinceEpoch,
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
    final settingsController = context.read<SettingsController>();
    final walletController = context.read<WalletController>();
    final colorScheme = Theme.of(context).colorScheme;
    final wallets = walletController.wallets;
    final isRpg = settingsController.isRpgMode;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          widget.isTransfer
              ? ScreenDict.newTranfer.get(isRpg)
              : ScreenDict.recordIncome.get(isRpg),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: _buildBottomBar(isRpg),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  items: wallets.map((wallet) {
                    return DropdownMenuItem(
                      value: wallet,
                      child: Text(wallet.name),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null || value.id == 0) {
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
                    items: wallets
                        .where((e) => e.id != _selectedWallet?.id)
                        .map((wallet) {
                          return DropdownMenuItem(
                            value: wallet,
                            child: Text(wallet.name),
                          );
                        })
                        .toList(),
                    validator: (value) {
                      if (widget.isTransfer &&
                          (value == null || value.id == 0)) {
                        return UiDict.requiredWalletDest;
                      }
                      return null;
                    },
                    onChanged: (val) => setState(() => _selectedTarget = val),
                  ),
                  const SizedBox(height: 16),
                ],

                CustomDateTimePicker(
                  initialDate: _selectedDate,
                  label: ScreenDict.historyTime.get(isRpg),
                  onChanged: (newDate) {
                    setState(() {
                      _selectedDate = newDate;
                    });
                  },
                ),
                const SizedBox(height: 16),

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
                        value: TransactionCategory.loanDisbursement,
                        child: Text(CategoryDict.loanDisbursement.get(false)),
                      ),
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
                    color: colorScheme.onSurfaceVariant,
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
                        color: colorScheme.onSurfaceVariant,
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
                          max: NumberUtils.parseToDecimal(
                            _amountController.text,
                          ),
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
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    value: _isAllocationActive,
                    onChanged: (val) =>
                        setState(() => _isAllocationActive = val),
                  ),

                  if (_isAllocationActive) ...[
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.3),
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
                          Divider(
                            height: 1,
                            color: colorScheme.onSurface.withOpacity(0.2),
                          ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool isRpg) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: 24 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.onPrimary.withOpacity(0.2),
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
          ],
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                if (widget.isTransfer) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ScreenDict.getHomeIncome(
                          _selectedWallet?.name ?? '',
                          isExpense: true,
                          isRpg: isRpg,
                        ),
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      Text(
                        NumberUtils.toIdr(_cleanAmount),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ScreenDict.getHomeIncome(
                        widget.isTransfer
                            ? _selectedTarget?.name ?? ''
                            : _selectedWallet?.name ?? '',
                        isExpense: false,
                        isRpg: isRpg,
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
            title: widget.isTransfer
                ? UiDict.transfer.get(isRpg)
                : ScreenDict.saveIncome.get(isRpg),
            color: colorScheme.primary,
            onTap: _submit,
          ),
        ],
      ),
    );
  }

  Widget _buildAllocationRow(Enum name, double percentage) {
    final colorScheme = Theme.of(context).colorScheme;

    double amount = _onePercentageAmount * percentage;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            GamificationDict.getSkillByEnum(name).get(false),
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          ),
        ),

        Expanded(
          flex: 1,
          child: Text(
            "${percentage.toInt().toString()}%",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
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
