import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../controllers/settings_controller.dart';
import '../../../controllers/wallet_controller.dart';
import '../../../core/constants/screen_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/utils/enum_types.dart';
import '../../../core/utils/number_utils.dart';
import '../../../models/transaction_detail_model.dart';
import '../../../models/transaction_model.dart';
import '../../../models/wallet_model.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_date_time_picker.dart';
import '../../../widgets/note_container.dart';

class PayBillModal extends StatefulWidget {
  final TransactionModel transaction;
  const PayBillModal({super.key, required this.transaction});

  @override
  State<PayBillModal> createState() => _PayBillModalState();
}

class _PayBillModalState extends State<PayBillModal> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController(text: '0');
  final _feeController = TextEditingController(text: '0');

  DateTime _selectedDate = DateTime.now();
  WalletModel? _selectedWallet;
  Decimal _amount = Decimal.zero;
  bool _isSavingsActive = false;
  bool _isFeeActive = false;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    final detail = transaction.detailTransaction;
    _titleController.text = transaction.title;
    if (detail.isNotEmpty) {
      NumberUtils.formatInput(
        _amountController,
        detail[0].amount.toString(),
        onCalculated: _calculateTotal,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    try {
      Decimal total = NumberUtils.parseToDecimal(_amountController.text);
      if (_isFeeActive) {
        total += NumberUtils.parseToDecimal(_feeController.text);
      }
      setState(() {
        _amount = total;
      });
    } catch (e) {
      _amount = Decimal.zero;
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final transaction = widget.transaction;
      final detail = transaction.detailTransaction[0];
      List<TransactionDetailModel> newDetail = [
        TransactionDetailModel(
          id: detail.id,
          title: detail.title,
          amount: NumberUtils.parseToDecimal(_amountController.text),
          category: detail.category,
          flow: FlowType.expense,
        ),
      ];

      if (_isFeeActive) {
        newDetail.add(
          TransactionDetailModel(
            title: 'Fee',
            amount: NumberUtils.parseToDecimal(_feeController.text),
            category: TransactionCategory.utilities,
            flow: FlowType.expense,
          ),
        );
      }

      TransactionModel newTrans = TransactionModel(
        id: transaction.id,
        walletId: _selectedWallet!.id,
        billId: transaction.billId,
        debtId: transaction.debtId,
        type: transaction.type,
        title: _titleController.text.trim(),
        amount: _amount,
        status: StatusType.paid,
        detailTransaction: newDetail,
        dateTimestamp: _selectedDate.millisecondsSinceEpoch,
      );

      Navigator.pop(context, {
        "transaction": newTrans,
        'use_reserved': _isSavingsActive,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final colorScheme = Theme.of(context).colorScheme;

    final isRpg = context.read<SettingsController>().isRpgMode;
    final walletController = context.read<WalletController>();
    final wallets = walletController.allWallets;

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
                    color: colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Text(
                'Bayar tagihan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: ScreenDict.billName.get(isRpg),
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? UiDict.requiredName : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: UiDict.amount,
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => NumberUtils.formatInput(
                  _amountController,
                  val,
                  onCalculated: _calculateTotal,
                ),
                validator: (val) =>
                    val == null || !NumberUtils.isValidAmount(val)
                    ? UiDict.requiredPrice
                    : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<WalletModel>(
                initialValue: _selectedWallet,
                decoration: InputDecoration(
                  labelText: UiDict.sourceFunds,
                  border: OutlineInputBorder(),
                ),
                items:
                    (_isSavingsActive
                            ? wallets
                            : wallets.where((w) => !w.isSavings).toList())
                        .map(
                          (wallet) => DropdownMenuItem(
                            value: wallet,
                            child: Text(
                              walletController.getDisplayName(wallet),
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _selectedWallet = val),
                validator: (val) => val == null ? UiDict.requiredWallet : null,
              ),
              const SizedBox(height: 16),

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

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  UiDict.feeCheck,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                subtitle: Text(
                  ScreenDict.getFeeCheckDesc(isRpg: isRpg),
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
                  onChanged: (val) => NumberUtils.formatInput(
                    _feeController,
                    val,
                    onCalculated: _calculateTotal,
                  ),
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
                  text: "Note: ${ScreenDict.getFeeCheckDesc(isRpg: isRpg)}",
                  color: colorScheme.onSurfaceVariant,
                ),
              ],

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  ScreenDict.getReservedCheck(isRpg: isRpg),
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                subtitle: Text(
                  ScreenDict.getReservedCheckDesc(isRpg: isRpg),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                value: _isSavingsActive,
                onChanged: (val) => setState(() {
                  _isSavingsActive = val;
                  if (!val &&
                      _selectedWallet != null &&
                      _selectedWallet!.isSavings) {
                    _selectedWallet = null;
                  }
                }),
              ),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.onPrimary.withValues(alpha: 0.2),
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
                        text: ScreenDict.getHistoryNote(
                          walletController.getDisplayName(_selectedWallet!),
                          NumberUtils.toIdr(_selectedWallet?.amount),
                        ),
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ScreenDict.expenseAmount.get(isRpg),
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              NumberUtils.toIdr(_amount),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      title: ScreenDict.getPayBill(isRpg: isRpg),
                      color: colorScheme.primary,
                      onTap: _submit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
