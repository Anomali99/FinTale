import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../controllers/settings_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/screen_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/enum_types.dart';
import '../../../models/bill_model.dart';
import '../../../models/debt_model.dart';
import '../../../models/transaction_detail_model.dart';
import '../../../models/transaction_model.dart';
import '../../../models/wallet_model.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/note_container.dart';

class PayDebtModal extends StatefulWidget {
  final String? title;
  final List<WalletModel> wallets;
  final List<DebtModel>? debts;
  final List<BillModel>? bils;
  final BigInt? pendingAllocation;
  const PayDebtModal({
    super.key,
    required this.wallets,
    this.title,
    this.debts,
    this.bils,
    this.pendingAllocation,
  });

  @override
  State<PayDebtModal> createState() => _PayDebtModalState();
}

class _PayDebtModalState extends State<PayDebtModal>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  final _amountController = TextEditingController(text: '0');
  final _feeController = TextEditingController(text: '0');

  WalletModel? _selectedWallet;
  DebtModel? _selectedDebt;
  BillModel? _selectedBill;
  BigInt _amount = BigInt.zero;
  bool _isReservedActive = false;
  bool _isFeeActive = false;

  bool _isBillTab = true;
  bool _isHideTab = false;
  bool _isLockWallet = false;

  BigInt get _cleanAmount => _amountController.text.isNotEmpty
      ? BigInt.parse(_amountController.text.replaceAll('.', ''))
      : BigInt.zero;

  BigInt get _cleanFeeAmount => _feeController.text.isNotEmpty
      ? BigInt.parse(_feeController.text.replaceAll('.', ''))
      : BigInt.zero;

  @override
  void initState() {
    super.initState();

    int initialIndex = 1;
    if (widget.bils?.length == 1 && (widget.debts?.isEmpty ?? true)) {
      initialIndex = 0;
      _isHideTab = true;
    }
    if (widget.debts?.length == 1 && (widget.bils?.isEmpty ?? true)) {
      initialIndex = 1;
      _isHideTab = true;
    }
    if (widget.bils != null && widget.bils!.isNotEmpty) {
      _selectedBill = widget.bils?[0];
      _onNumberChanged(
        _amountController,
        _selectedBill?.amount.toString() ?? '0',
      );
    }
    if (widget.debts != null && widget.debts!.isNotEmpty) {
      _selectedDebt = widget.debts?[0];
    }

    _isBillTab = initialIndex == 0;

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: initialIndex,
    );

    if (widget.wallets.length == 1) {
      _isLockWallet = true;
      _selectedWallet = widget.wallets[0];
    }

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _isBillTab = _tabController.index == 0;
          _resetForm();
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _feeController.text = '0';
    _isReservedActive = false;
    _isFeeActive = false;
    if (_isBillTab) {
      _onNumberChanged(
        _amountController,
        _selectedBill?.amount.toString() ?? '0',
      );
    } else {
      _onNumberChanged(_amountController, '0');
    }
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
      TransactionModel transaction;
      if (_isBillTab) {
        transaction = _selectedBill!.generateTransaction(
          status: StatusType.paid,
          walletId: _selectedWallet?.id,
          totalAmount: _amount,
          detailAmount: _cleanAmount,
        );
      } else {
        transaction = _selectedDebt!.generateTransaction(
          walletId: _selectedWallet?.id,
          totalAmount: _amount,
          detailAmount: _cleanAmount,
        );
      }

      if (_isFeeActive) {
        transaction.detailTransaction.add(
          TransactionDetailModel(
            title: 'Fee',
            amount: _cleanFeeAmount,
            category: TransactionCategory.utilities,
            flow: FlowType.expense,
          ),
        );
      }

      Navigator.pop(context, {
        "is_bill": _isBillTab,
        "transaction": transaction,
        'use_reserved': _isReservedActive,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isRpg = context.read<SettingsController>().isRpgMode;

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
              if (_isHideTab)
                Text(
                  widget.title ??
                      ScreenDict.getBillTypes(
                        isBillDebt: !_isBillTab,
                        isRpg: isRpg,
                      ),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )
              else
                Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.5),
                      ),
                    ),
                    labelColor: AppColors.primary,
                    labelStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    unselectedLabelColor: AppColors.textSecondary,
                    tabs: [
                      Tab(
                        text: ScreenDict.getBillTypes(
                          isBillDebt: false,
                          isRpg: isRpg,
                        ),
                      ),
                      Tab(
                        text: ScreenDict.getBillTypes(
                          isBillDebt: true,
                          isRpg: isRpg,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              if (_isBillTab)
                DropdownButtonFormField<BillModel>(
                  initialValue: _selectedBill,
                  decoration: InputDecoration(
                    labelText: ScreenDict.billsMaster.get(isRpg),
                    border: OutlineInputBorder(),
                  ),
                  items: (widget.bils ?? [])
                      .map(
                        (a) => DropdownMenuItem(value: a, child: Text(a.title)),
                      )
                      .toList(),
                  onChanged: widget.bils != null && widget.bils!.length > 1
                      ? (val) => setState(() {
                          _selectedBill = val;
                          _onNumberChanged(
                            _amountController,
                            val!.amount.toString(),
                          );
                        })
                      : null,
                  validator: (val) => val == null && !_isBillTab
                      ? ScreenDict.billAmount.get(isRpg)
                      : null,
                )
              else
                DropdownButtonFormField<DebtModel>(
                  initialValue: _selectedDebt,
                  decoration: InputDecoration(
                    labelText: ScreenDict.debtsMaster.get(isRpg),
                    border: OutlineInputBorder(),
                  ),
                  items: (widget.debts ?? [])
                      .map(
                        (a) => DropdownMenuItem(value: a, child: Text(a.title)),
                      )
                      .toList(),
                  onChanged: widget.debts != null && widget.debts!.length > 1
                      ? (val) => setState(() {
                          _selectedDebt = val;
                        })
                      : null,
                  validator: (val) => val == null && !_isBillTab
                      ? ScreenDict.debtRequired.get(isRpg)
                      : null,
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
                items: widget.wallets
                    .map(
                      (wallet) => DropdownMenuItem(
                        value: wallet,
                        child: Text(wallet.name),
                      ),
                    )
                    .toList(),
                onChanged: !_isLockWallet
                    ? (val) => setState(() => _selectedWallet = val)
                    : null,
                validator: (val) => val == null ? UiDict.requiredWallet : null,
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  UiDict.feeCheck,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  ScreenDict.getFeeCheckDesc(isRpg: isRpg),
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
                  onChanged: (value) => _onNumberChanged(_feeController, value),
                ),
                const SizedBox(height: 12),
                NoteContainer(
                  text: "Note: ${ScreenDict.getFeeCheckDesc(isRpg: isRpg)}",
                  color: Colors.grey,
                ),
              ],

              if (widget.pendingAllocation == null)
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
                        text: widget.pendingAllocation != null
                            ? ScreenDict.getInvestNote(
                                _selectedWallet?.name ?? '',
                                CurrencyFormatter.convertToIdr(
                                  widget.pendingAllocation,
                                ),
                              )
                            : _isReservedActive
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
                      title: _isBillTab
                          ? ScreenDict.getPayBill(isRpg: isRpg)
                          : ScreenDict.getPayDebt(
                              isCustom: false,
                              isRpg: isRpg,
                            ),
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
