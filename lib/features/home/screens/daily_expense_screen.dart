import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
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
import '../../../widgets/note_container.dart';

class ExpenseItemForm {
  TextEditingController titleController;
  TextEditingController amountController;
  TransactionCategory? category;

  ExpenseItemForm({
    required this.titleController,
    required this.amountController,
    this.category,
  });
}

class DailyExpenseScreen extends StatefulWidget {
  const DailyExpenseScreen({super.key});

  @override
  State<DailyExpenseScreen> createState() => _DailyExpenseScreenState();
}

class _DailyExpenseScreenState extends State<DailyExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  final _mainTitleController = TextEditingController();
  final _feeController = TextEditingController(text: '0');
  DateTime _selectedDate = DateTime.now();
  WalletModel? _selectedWallet;

  Decimal _totalAmount = Decimal.zero;
  bool _isExcludeActive = false;
  bool _isReservedActive = false;
  bool _isFeeActive = false;

  final List<ExpenseItemForm> _items = [];

  @override
  void initState() {
    super.initState();
    _addNewItem();
  }

  @override
  void dispose() {
    _mainTitleController.dispose();
    _feeController.dispose();
    for (var item in _items) {
      item.titleController.dispose();
      item.amountController.dispose();
    }
    super.dispose();
  }

  void _addNewItem() {
    setState(() {
      _items.add(
        ExpenseItemForm(
          titleController: TextEditingController(),
          amountController: TextEditingController(text: ''),
        ),
      );
    });
  }

  void _removeItem(int index) {
    if (_items.length > 1) {
      setState(() {
        _items[index].titleController.dispose();
        _items[index].amountController.dispose();
        _items.removeAt(index);
      });
    }
  }

  void _calculateTotal() {
    try {
      Decimal total = Decimal.zero;
      for (var item in _items) {
        total += NumberUtils.parseToDecimal(item.amountController.text);
      }
      if (_isFeeActive) {
        total += NumberUtils.parseToDecimal(_feeController.text);
      }
      setState(() {
        _totalAmount = total;
      });
    } catch (e) {
      _totalAmount = Decimal.zero;
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      List<TransactionDetailModel> details = [];

      for (var item in _items) {
        details.add(
          TransactionDetailModel(
            title: item.titleController.text.trim(),
            amount: NumberUtils.parseToDecimal(item.amountController.text),
            category: item.category!,
            flow: FlowType.expense,
          ),
        );
      }

      if (_isFeeActive) {
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
        title: _mainTitleController.text.trim(),
        amount: _totalAmount,
        type: TransactionType.expense,
        status: StatusType.paid,
        dateTimestamp: _selectedDate.millisecondsSinceEpoch,
        walletId: _selectedWallet?.id,
        detailTransaction: details,
      );

      Navigator.pop(context, {
        "transaction": transaction,
        'use_reserved': _isReservedActive,
        'exclude_daily': _isExcludeActive,
      });
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      if (!context.mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      } else {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            _selectedDate.hour,
            _selectedDate.minute,
          );
        });
      }
    }
  }

  void _resetToCurrentTime() {
    setState(() {
      _selectedDate = DateTime.now();
    });
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
          ScreenDict.recordExpense.get(isRpg),
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
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            Text(
              ScreenDict.historyInformation,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _mainTitleController,
              decoration: const InputDecoration(
                labelText: UiDict.title,
                border: OutlineInputBorder(),
              ),
              validator: (val) => val == null || val.trim().isEmpty
                  ? UiDict.requiredTitle
                  : null,
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<WalletModel>(
              initialValue: _selectedWallet,
              decoration: const InputDecoration(
                labelText: UiDict.sourceFunds,
                border: OutlineInputBorder(),
              ),
              items: wallets.map((entry) {
                return DropdownMenuItem(value: entry, child: Text(entry.name));
              }).toList(),
              onChanged: (val) => setState(() => _selectedWallet = val),
              validator: (val) => val == null ? UiDict.requiredWallet : null,
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: ScreenDict.historyTime.get(isRpg),
                        border: const OutlineInputBorder(),
                      ),
                      child: Text(
                        DateFormat(
                          'dd MMMM yyyy •󠁏󠁏 HH:mm',
                        ).format(_selectedDate),
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 51,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: colorScheme.onSurface.withOpacity(0.38),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: IconButton(
                    onPressed: _resetToCurrentTime,
                    icon: FaIcon(
                      FontAwesomeIcons.arrowRotateLeft,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
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
                  _isExcludeActive = val;
                }
              }),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                ScreenDict.getExcludeDailyCheck(isRpg: isRpg),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                ScreenDict.getExcludeDailyCheckDesc(isRpg: isRpg),
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              value: _isExcludeActive,
              onChanged: (val) => setState(() => _isExcludeActive = val),
            ),

            Divider(height: 1, color: colorScheme.onSurface.withOpacity(0.2)),
            const SizedBox(height: 32),

            Text(
              ScreenDict.breakdownDetail,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),

            ..._items.asMap().entries.map((entry) {
              int index = entry.key;
              ExpenseItemForm item = entry.value;

              return Card(
                elevation: 0,
                color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                margin: const EdgeInsets.only(bottom: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: colorScheme.onSurface.withOpacity(0.1),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Item #${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          if (_items.length > 1)
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: colorScheme.error,
                              ),
                              onPressed: () => _removeItem(index),
                              tooltip: UiDict.deleteItem,
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: item.titleController,
                        decoration: const InputDecoration(
                          labelText: UiDict.name,
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? UiDict.requiredName
                            : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: item.amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          labelText: UiDict.price,
                          prefixText: 'Rp ',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) => NumberUtils.formatInput(
                          item.amountController,
                          val,
                          onCalculated: _calculateTotal,
                        ),
                        validator: (val) {
                          if (val == null || !NumberUtils.isValidAmount(val)) {
                            return UiDict.requiredPrice;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<TransactionCategory>(
                        initialValue: item.category,
                        decoration: const InputDecoration(
                          labelText: UiDict.category,
                          border: OutlineInputBorder(),
                        ),
                        items: TransactionCategory.expenseCategories.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(cat.categoryDict.get(isRpg)),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => item.category = val),
                        validator: (val) =>
                            val == null ? UiDict.requiredCategory : null,
                      ),
                    ],
                  ),
                ),
              );
            }),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: OutlinedButton.icon(
                onPressed: _addNewItem,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: colorScheme.primary,
                    style: BorderStyle.solid,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.add, color: colorScheme.primary),
                label: Text(
                  UiDict.addItem,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
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
                    NumberUtils.toIdr(_totalAmount),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: colorScheme.error,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomButton(
            title: ScreenDict.saveExpense.get(isRpg),
            color: colorScheme.error,
            onTap: _submitForm,
          ),
        ],
      ),
    );
  }
}
