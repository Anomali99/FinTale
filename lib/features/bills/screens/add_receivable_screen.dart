import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../controllers/settings_controller.dart';
import '../../../controllers/wallet_controller.dart';
import '../../../core/constants/screen_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/number_utils.dart';
import '../../../models/receivable_model.dart';
import '../../../models/transaction_model.dart';
import '../../../models/wallet_model.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_date_time_picker.dart';
import '../../../widgets/note_container.dart';

class AddReceivableScreen extends StatefulWidget {
  final ReceivableModel? initialReceivable;
  final List<String> existingNames;

  const AddReceivableScreen({
    super.key,
    this.initialReceivable,
    this.existingNames = const [],
  });

  @override
  State<AddReceivableScreen> createState() => _AddReceivableScreenState();
}

class _AddReceivableScreenState extends State<AddReceivableScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _borrowerController;
  final _titleController = TextEditingController();
  final _amountController = TextEditingController(text: '0');
  final _feeController = TextEditingController(text: '0');

  DateTime _selectedDate = DateTime.now();
  DateTime? _targetDate;

  WalletModel? _selectedWallet;

  bool _hasTargetDate = false;
  bool _isReminderActive = false;
  bool _isFeeActive = false;
  bool _isReservedActive = false;

  Decimal get _cleanAmount =>
      NumberUtils.parseToDecimal(_amountController.text);
  Decimal get _cleanFee => NumberUtils.parseToDecimal(_feeController.text);

  Decimal? get _maxAmount {
    if (_isReservedActive) return _selectedWallet?.reservedAmount;
    return _selectedWallet?.amount;
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialReceivable != null) {
      final r = widget.initialReceivable!;
      _titleController.text = r.title;
      _selectedDate = DateTime.fromMillisecondsSinceEpoch(r.dateTimestamp);
      _onAmountChanged(r.amount.toString());

      if (r.targetDate != null) {
        _hasTargetDate = true;
        _isReminderActive = r.isReminderActive;
        _targetDate = DateTime.fromMillisecondsSinceEpoch(r.targetDate!);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String value) {
    Decimal currentValue = NumberUtils.parseToDecimal(value);

    if (_maxAmount != null && currentValue > _maxAmount!) {
      currentValue = _maxAmount!;
    }
    NumberUtils.formatInput(_amountController, currentValue.toString());

    Decimal feeValue = NumberUtils.parseToDecimal(_feeController.text);
    if (feeValue > currentValue) {
      NumberUtils.formatInput(_feeController, currentValue.toString());
    }
    setState(() {});
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ReceivableModel receivable = ReceivableModel(
        id: widget.initialReceivable?.id,
        title: _titleController.text.trim(),
        borrowerName: _borrowerController.text.trim(),
        paidAmount: widget.initialReceivable?.paidAmount,
        amount: _cleanAmount,
        isReminderActive: _hasTargetDate && _isReminderActive,
        dateTimestamp: _selectedDate.millisecondsSinceEpoch,
        targetDate: _targetDate?.millisecondsSinceEpoch,
      );

      if (widget.initialReceivable == null) {
        TransactionModel transaction = receivable.generateTransaction(
          walletId: _selectedWallet?.id,
          feeAmount: _isFeeActive ? _cleanFee : null,
        );

        Navigator.pop(context, {
          "receivable": receivable,
          "transaction": transaction,
          "use_reserved": _isReservedActive,
        });
      } else {
        Navigator.pop(context, {
          "receivable": receivable,
          "transaction": null,
          "use_reserved": null,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = context.read<SettingsController>();
    final walletController = context.read<WalletController>();
    final colorScheme = Theme.of(context).colorScheme;
    final isRpg = settingsController.isRpgMode;
    final wallets = walletController.wallets;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          widget.initialReceivable != null
              ? UiDict.getEdit(ScreenDict.receivableMaster.get(isRpg))
              : ScreenDict.addReceivable.get(isRpg),
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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Autocomplete<String>(
                initialValue: TextEditingValue(
                  text: widget.initialReceivable?.borrowerName ?? '',
                ),
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return widget.existingNames.where((String option) {
                    return option.toLowerCase().contains(
                      textEditingValue.text.toLowerCase(),
                    );
                  });
                },
                fieldViewBuilder:
                    (
                      context,
                      textEditingController,
                      focusNode,
                      onFieldSubmitted,
                    ) {
                      _borrowerController = textEditingController;

                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: UiDict.name,
                          prefixIcon: const Icon(Icons.person_outline),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? UiDict.requiredName
                            : null,
                        onFieldSubmitted: (String value) => onFieldSubmitted(),
                      );
                    },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      borderRadius: BorderRadius.circular(12),
                      color: colorScheme.surfaceContainerHighest,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: 200,
                          maxWidth: MediaQuery.of(context).size.width - 48,
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final String option = options.elementAt(index);
                            return InkWell(
                              onTap: () => onSelected(option),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 12.0,
                                ),
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: UiDict.title,
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? UiDict.requiredTitle
                    : null,
              ),
              const SizedBox(height: 16),
              if (widget.initialReceivable == null) ...[
                DropdownButtonFormField<WalletModel>(
                  initialValue: _selectedWallet,
                  decoration: InputDecoration(
                    labelText: UiDict.sourceFunds,
                    border: const OutlineInputBorder(),
                  ),
                  items: wallets.map((wallet) {
                    return DropdownMenuItem(
                      value: wallet,
                      child: Text(wallet.name),
                    );
                  }).toList(),
                  validator: (val) =>
                      val == null || widget.initialReceivable != null
                      ? UiDict.requiredWallet
                      : null,
                  onChanged: (val) {
                    setState(() => _selectedWallet = val);
                    _onAmountChanged(_amountController.text);
                  },
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: UiDict.amount,
                  prefixText: 'Rp ',
                  border: const OutlineInputBorder(),
                ),
                validator: (val) => val == null || val == '0' || val.isEmpty
                    ? UiDict.requiredAmount
                    : null,
                onChanged: _onAmountChanged,
              ),
              const SizedBox(height: 16),

              if (widget.initialReceivable == null) ...[
                CustomDateTimePicker(
                  initialDate: _selectedDate,
                  label: ScreenDict.receivableDate.get(isRpg),
                  onChanged: (newDate) =>
                      setState(() => _selectedDate = newDate),
                ),
                const SizedBox(height: 12),
              ],

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  ScreenDict.getTargetDateCheck(isRpg: isRpg),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  ScreenDict.getDebtBillDesc(isRpg: isRpg),
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                value: _hasTargetDate,
                onChanged: (val) {
                  setState(() {
                    _hasTargetDate = val;
                    if (val) {
                      _targetDate = DateTime.now().add(const Duration(days: 7));
                      _isReminderActive = true;
                    } else {
                      _targetDate = null;
                      _isReminderActive = false;
                    }
                  });
                },
              ),

              if (_hasTargetDate) ...[
                const SizedBox(height: 8),
                CustomDateTimePicker(
                  initialDate: _targetDate!,
                  label: ScreenDict.receivableTarget.get(isRpg),
                  onChanged: (newDate) => setState(() => _targetDate = newDate),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    ScreenDict.notificationCheck,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    ScreenDict.getNotificationDesc(isRpg: isRpg),
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  value: _isReminderActive,
                  onChanged: (val) => setState(() => _isReminderActive = val),
                ),
              ],

              if (widget.initialReceivable == null) ...[
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    UiDict.feeCheck,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Note: ${ScreenDict.getFeeCheckDesc(isIncome: false, isRpg: isRpg)}",
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
                    decoration: const InputDecoration(
                      labelText: UiDict.feeAmount,
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) =>
                        _isFeeActive &&
                            (val == null || val == '0' || val.isEmpty)
                        ? UiDict.requiredFee
                        : null,
                    onChanged: (val) {
                      Decimal currentFee = NumberUtils.parseToDecimal(val);
                      if (currentFee > _cleanAmount) currentFee = _cleanAmount;
                      NumberUtils.formatInput(
                        _feeController,
                        currentFee.toString(),
                      );
                      setState(() {});
                    },
                  ),
                ],
                const SizedBox(height: 8),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    ScreenDict.getReservedCheck(isRpg: isRpg),
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
                      _onAmountChanged(_amountController.text);
                    }
                  }),
                ),
              ],
            ],
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
            color: colorScheme.onPrimary.withOpacity(0.1),
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.initialReceivable == null) ...[
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
              const SizedBox(height: 12),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ScreenDict.getHomeIncome(
                          _selectedWallet?.name ?? '',
                          isExpense: false,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ScreenDict.totalReceived,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      Text(
                        NumberUtils.toIdr(
                          _cleanAmount -
                              (_isFeeActive ? _cleanFee : Decimal.zero),
                        ),
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
          ],
          CustomButton(
            title: ScreenDict.receivableApply.get(isRpg),
            color: colorScheme.primary,
            onTap: _submit,
          ),
        ],
      ),
    );
  }
}
