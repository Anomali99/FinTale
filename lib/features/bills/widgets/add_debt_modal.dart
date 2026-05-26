import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../controllers/settings_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/screen_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/utils/enum_types.dart';
import '../../../models/bill_model.dart';
import '../../../models/debt_model.dart';
import '../../../widgets/custom_button.dart';

class AddDebtModal extends StatefulWidget {
  final DebtModel? initialDebt;
  const AddDebtModal({super.key, this.initialDebt});

  @override
  State<AddDebtModal> createState() => _AddDebtModalState();
}

class _AddDebtModalState extends State<AddDebtModal> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _paidAmountController = TextEditingController(text: '0');

  final _installmentController = TextEditingController();

  DebtType _selectedType = DebtType.other;
  bool _createBill = false;
  TimeType _billFrequency = TimeType.monthly;
  int _billDay = 1;

  @override
  void initState() {
    super.initState();
    final initialValue = widget.initialDebt;
    if (initialValue != null) {
      _titleController.text = initialValue.title;
      _selectedType = initialValue.type;
      _onNumberChanged(_totalAmountController, initialValue.amount.toString());
      _onNumberChanged(
        _paidAmountController,
        initialValue.paidAmount.toString(),
      );

      final initialBill = initialValue.bill;
      if (initialBill != null) {
        _createBill = initialBill.isActive;
        _billDay = initialBill.day ?? initialBill.dayName?.intValue ?? 1;
        _billFrequency = initialBill.type;
        _onNumberChanged(_installmentController, initialBill.amount.toString());
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _totalAmountController.dispose();
    _paidAmountController.dispose();
    _installmentController.dispose();
    super.dispose();
  }

  void _onNumberChanged(TextEditingController controller, String value) {
    String cleanText = value.replaceAll('.', '');
    if (cleanText.isEmpty) {
      controller.text = '';
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
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      BillModel? bill;
      if (_createBill || widget.initialDebt?.bill != null) {
        bill = BillModel(
          id: widget.initialDebt?.bill?.id,
          title: ScreenDict.getDebtBillTitle(_titleController.text.trim()),
          amount: BigInt.parse(_installmentController.text.replaceAll('.', '')),
          type: _billFrequency,
          isActive: _createBill,
          dayName: _billFrequency == TimeType.weekly
              ? DayName.getByIntValue(_billDay)
              : null,
          day: _billFrequency == TimeType.monthly ? _billDay : null,
        );
      }

      DebtModel debt = DebtModel(
        id: widget.initialDebt?.id,
        title: _titleController.text.trim(),
        amount: BigInt.parse(_totalAmountController.text.replaceAll('.', '')),
        paidAmount: BigInt.parse(
          _paidAmountController.text.replaceAll('.', ''),
        ),
        type: _selectedType,
        bill: bill,
      );

      Navigator.pop(context, debt);
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
              Text(
                ScreenDict.addDebt.get(isRpg),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: ScreenDict.debtName.get(isRpg),
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? UiDict.requiredName : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<DebtType>(
                initialValue: _selectedType,
                decoration: InputDecoration(
                  labelText: ScreenDict.debtType.get(isRpg),
                  border: OutlineInputBorder(),
                ),
                items: DebtType.values
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.name.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _totalAmountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: ScreenDict.debtAmount.get(isRpg),
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) =>
                          _onNumberChanged(_totalAmountController, val),
                      validator: (val) =>
                          val == null ||
                              val.replaceAll('.', '').isEmpty ||
                              val.replaceAll('.', '') == '0'
                          ? ScreenDict.debtAmountRequired.get(isRpg)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _paidAmountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: ScreenDict.debtPayAmount.get(isRpg),
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) =>
                          _onNumberChanged(_paidAmountController, val),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  ScreenDict.debtBillCheck.get(isRpg),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(ScreenDict.getDebtBillDesc(isRpg: isRpg)),
                value: _createBill,
                onChanged: (val) => setState(() => _createBill = val),
              ),

              if (_createBill) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _installmentController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: ScreenDict.debtBillAmount.get(isRpg),
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) =>
                      _onNumberChanged(_installmentController, val),
                  validator: (val) =>
                      _createBill &&
                          (val == null ||
                              val.replaceAll('.', '').isEmpty ||
                              val.replaceAll('.', '') == '0')
                      ? UiDict.requiredAmount
                      : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<TimeType>(
                        initialValue: _billFrequency,
                        decoration: InputDecoration(
                          labelText: ScreenDict.billType.get(isRpg),
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: TimeType.monthly,
                            child: Text(TimeType.monthly.value),
                          ),
                          DropdownMenuItem(
                            value: TimeType.weekly,
                            child: Text(TimeType.weekly.value),
                          ),
                        ],
                        onChanged: (val) =>
                            setState(() => _billFrequency = val!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        initialValue: _billDay.toString(),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: _billFrequency == TimeType.monthly
                              ? UiDict.date
                              : UiDict.onDay,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (val) => _billDay = int.tryParse(val) ?? 1,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 32),
              CustomButton(
                title: UiDict.addNew,
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
