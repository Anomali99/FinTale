import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../controllers/settings_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/screen_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/utils/enum_types.dart';
import '../../../models/bill_model.dart';
import '../../../widgets/custom_button.dart';

class AddBillModal extends StatefulWidget {
  final BillModel? initialBill;
  const AddBillModal({super.key, this.initialBill});

  @override
  State<AddBillModal> createState() => _AddBillModalState();
}

class _AddBillModalState extends State<AddBillModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime? _currentNextDueDate;
  TimeType _selectedType = TimeType.monthly;
  DayName _selectedDayName = DayName.monday;
  int _selectedDay = 1;
  int _selectedMonth = 1;
  bool _isLockActive = false;

  @override
  void initState() {
    super.initState();
    final initialValue = widget.initialBill;
    if (initialValue != null) {
      _titleController.text = initialValue.title;
      _selectedType = initialValue.type;
      _selectedDayName = initialValue.dayName ?? DayName.monday;
      _selectedMonth = initialValue.month ?? 1;
      _selectedDay = initialValue.day ?? 1;
      _isLockActive = !initialValue.isActive;
      _currentNextDueDate = initialValue.targetDate;

      String formattedText = initialValue.amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
      _amountController.value = TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _shiftDate(int step) {
    if (_currentNextDueDate == null) return;
    DateTime cur = _currentNextDueDate!;

    setState(() {
      if (_selectedType == TimeType.daily) {
        _currentNextDueDate = cur.add(Duration(days: step));
      } else if (_selectedType == TimeType.weekly) {
        _currentNextDueDate = cur.add(Duration(days: 7 * step));
      } else if (_selectedType == TimeType.monthly) {
        _currentNextDueDate = DateTime(cur.year, cur.month + step, cur.day);
      } else if (_selectedType == TimeType.annual) {
        _currentNextDueDate = DateTime(cur.year + step, cur.month, cur.day);
      }
    });
  }

  bool _canGoPrev() {
    if (_currentNextDueDate == null) return false;

    DateTime cur = _currentNextDueDate!;
    DateTime nextPrev;

    if (_selectedType == TimeType.daily) {
      nextPrev = cur.subtract(const Duration(days: 1));
    } else if (_selectedType == TimeType.weekly) {
      nextPrev = cur.subtract(const Duration(days: 7));
    } else if (_selectedType == TimeType.monthly) {
      nextPrev = DateTime(cur.year, cur.month - 1, cur.day);
    } else {
      nextPrev = DateTime(cur.year - 1, cur.month, cur.day);
    }

    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);

    return !nextPrev.isBefore(today);
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final bill = BillModel(
        id: widget.initialBill?.id,
        title: _titleController.text.trim(),
        amount: BigInt.parse(_amountController.text.replaceAll('.', '')),
        isActive: !_isLockActive,
        type: _selectedType,
        day:
            _selectedType == TimeType.monthly ||
                _selectedType == TimeType.annual
            ? _selectedDay
            : null,
        month: _selectedType == TimeType.annual ? _selectedMonth : null,
        dayName: _selectedType == TimeType.weekly ? _selectedDayName : null,
        nextDueDate: _currentNextDueDate?.millisecondsSinceEpoch,
      );
      Navigator.pop(context, bill);
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
                widget.initialBill == null
                    ? ScreenDict.addBill.get(isRpg)
                    : UiDict.getEdit(ScreenDict.billsMaster.get(isRpg)),
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
                  labelText: ScreenDict.billAmount.get(isRpg),
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) {
                  String cleanText = val.replaceAll('.', '');
                  if (cleanText.isEmpty) return;
                  BigInt currentValue =
                      BigInt.tryParse(cleanText) ?? BigInt.zero;
                  String formattedText = currentValue
                      .toString()
                      .replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]}.',
                      );
                  _amountController.value = TextEditingValue(
                    text: formattedText,
                    selection: TextSelection.collapsed(
                      offset: formattedText.length,
                    ),
                  );
                },
                validator: (val) =>
                    val == null ||
                        val.replaceAll('.', '').isEmpty ||
                        val.replaceAll('.', '') == '0'
                    ? UiDict.requiredAmount
                    : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<TimeType>(
                initialValue: _selectedType,
                decoration: InputDecoration(
                  labelText: ScreenDict.billType.get(isRpg),
                  border: OutlineInputBorder(),
                ),
                items: TimeType.values
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.value.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
              const SizedBox(height: 16),

              if (_selectedType == TimeType.weekly)
                DropdownButtonFormField<DayName>(
                  initialValue: _selectedDayName,
                  decoration: InputDecoration(
                    labelText: ScreenDict.billDay.get(isRpg),
                    border: OutlineInputBorder(),
                  ),
                  items: DayName.values
                      .map(
                        (d) => DropdownMenuItem(
                          value: d,
                          child: Text(d.value.toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedDayName = val!),
                ),

              if (_selectedType == TimeType.monthly ||
                  _selectedType == TimeType.annual)
                TextFormField(
                  initialValue: _selectedDay.toString(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: ScreenDict.billDate.get(isRpg),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => _selectedDay = int.tryParse(val) ?? 1,
                ),

              if (_selectedType == TimeType.annual) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: _selectedMonth,
                  decoration: InputDecoration(
                    labelText: ScreenDict.billMonth.get(isRpg),
                    border: OutlineInputBorder(),
                  ),
                  items: MonthName.values
                      .map(
                        (d) => DropdownMenuItem(
                          value: d.intValue,
                          child: Text(d.value.toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedMonth = val!),
                ),
              ],

              if (widget.initialBill != null) ...[
                const SizedBox(height: 16),
                Text(
                  ScreenDict.nextBill.get(isRpg),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),

                        onPressed: _canGoPrev() ? () => _shiftDate(-1) : null,
                        color: _canGoPrev()
                            ? AppColors.primary
                            : Colors.grey.withOpacity(0.3),
                      ),
                      Text(
                        DateFormat('dd MMM yyyy').format(_currentNextDueDate!),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => _shiftDate(1),
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    ScreenDict.getBillLockCheck(isRpg: isRpg),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    ScreenDict.getBillLockCheckDesc(isRpg: isRpg),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  value: _isLockActive,
                  onChanged: (val) => setState(() => _isLockActive = val),
                ),
              ],

              const SizedBox(height: 32),
              CustomButton(
                title: widget.initialBill == null
                    ? UiDict.addNew
                    : UiDict.saveChanges,
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
