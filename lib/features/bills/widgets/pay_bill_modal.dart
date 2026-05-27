import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../controllers/settings_controller.dart';
import '../../../controllers/wallet_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/screen_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/enum_types.dart';
import '../../../models/transaction_detail_model.dart';
import '../../../models/transaction_model.dart';
import '../../../models/wallet_model.dart';
import '../../../widgets/custom_button.dart';
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

  WalletModel? _selectedWallet;
  BigInt _amount = BigInt.zero;
  bool _isReservedActive = false;
  bool _isFeeActive = false;

  BigInt get _cleanAmount => _amountController.text.isNotEmpty
      ? BigInt.parse(_amountController.text.replaceAll('.', ''))
      : BigInt.zero;

  BigInt get _cleanFeeAmount => _feeController.text.isNotEmpty
      ? BigInt.parse(_feeController.text.replaceAll('.', ''))
      : BigInt.zero;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    final detail = transaction.detailTransaction;
    _titleController.text = transaction.title;
    if (detail.isNotEmpty) {
      _onNumberChanged(_amountController, detail[0].amount.toString());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  void _onNumberChanged(TextEditingController controller, String value) {
    String cleanText = value.replaceAll('.', '');

    if (cleanText.isEmpty) {
      controller.text = '';
      _calculateTotal();
      return;
    }

    BigInt currentValue = BigInt.tryParse(cleanText) ?? BigInt.zero;
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
    _calculateTotal();
  }

  void _calculateTotal() {
    try {
      BigInt total = _cleanAmount;
      if (_isFeeActive) {
        total += _cleanFeeAmount;
      }
      setState(() {
        _amount = total;
      });
    } catch (e) {
      _amount = BigInt.zero;
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
          amount: _cleanAmount,
          category: detail.category,
          flow: FlowType.expense,
        ),
      ];

      if (_isFeeActive) {
        newDetail.add(
          TransactionDetailModel(
            title: 'Fee',
            amount: _cleanFeeAmount,
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
        title: _titleController.text,
        amount: _amount,
        status: StatusType.paid,
        detailTransaction: newDetail,
        dateTimestamp: DateTime.now().millisecondsSinceEpoch,
      );

      Navigator.pop(context, {
        "transaction": newTrans,
        'use_reserved': _isReservedActive,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isRpg = context.read<SettingsController>().isRpgMode;
    final wallets = context.read<WalletController>().wallets;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
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
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white24,
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
                onChanged: (val) => _onNumberChanged(_amountController, val),
                validator: (val) =>
                    val == null || val.isEmpty ? UiDict.requiredPrice : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<WalletModel>(
                initialValue: _selectedWallet,
                decoration: InputDecoration(
                  labelText: UiDict.sourceFunds,
                  border: OutlineInputBorder(),
                ),
                items: wallets
                    .map(
                      (wallet) => DropdownMenuItem(
                        value: wallet,
                        child: Text(wallet.name),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedWallet = val),
                validator: (val) => val == null ? UiDict.requiredWallet : null,
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(UiDict.feeCheck),
                subtitle: const Text(UiDict.feeCheckDesc),
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
                  onChanged: (value) => _onNumberChanged(_feeController, value),
                ),
                const SizedBox(height: 12),
                NoteContainer(
                  text: "Note: ${ScreenDict.getFeeCheckDesc(isRpg: isRpg)}",
                  color: Colors.grey,
                ),
              ],

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(ScreenDict.getReservedCheck(isRpg: isRpg)),
                subtitle: Text(ScreenDict.getReservedCheckDesc(isRpg: isRpg)),
                value: _isReservedActive,
                onChanged: (val) => setState(() {
                  if (_selectedWallet != null) {
                    _isReservedActive = val;
                  }
                }),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
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
                                CurrencyFormatter.convertToIdr(
                                  _selectedWallet?.reservedAmount,
                                ),
                                isRpg: isRpg,
                              )
                            : ScreenDict.getHistoryNote(
                                _selectedWallet?.name ?? '',
                                CurrencyFormatter.convertToIdr(
                                  _selectedWallet?.amount,
                                ),
                              ),
                        color: Colors.grey,
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
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.convertToIdr(_amount),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      title: 'Bayar',
                      color: AppColors.primary,
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
