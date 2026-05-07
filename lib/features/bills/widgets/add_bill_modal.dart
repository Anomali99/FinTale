import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/shared_dict.dart';
import '../../../models/bill_model.dart';
import '../../../widgets/custom_button.dart';

class AddBillModal extends StatefulWidget {
  const AddBillModal({super.key});

  @override
  State<AddBillModal> createState() => _AddBillModalState();
}

class _AddBillModalState extends State<AddBillModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  TimeType _selectedType = TimeType.monthly;
  DayName _selectedDayName = DayName.monday;
  int _selectedDay = 1;
  int _selectedMonth = 1;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final bill = BillModel(
        title: _titleController.text.trim(),
        amount: BigInt.parse(_amountController.text.replaceAll('.', '')),
        type: _selectedType,
        day: _selectedDay,
        month: _selectedMonth,
        dayName: _selectedDayName,
      );
      Navigator.pop(context, bill);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

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
              const Text(
                'Tambah Tagihan Baru',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Nama Tagihan',
                  hintText: 'Misal: Listrik, Netflix',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty
                    ? SharedDict.requiredTitle
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Nominal Tagihan',
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
                    val == null || val.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<TimeType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Siklus Penagihan',
                  border: OutlineInputBorder(),
                ),
                items: TimeType.values
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

              if (_selectedType == TimeType.weekly)
                DropdownButtonFormField<DayName>(
                  initialValue: _selectedDayName,
                  decoration: const InputDecoration(
                    labelText: 'Hari Penagihan',
                    border: OutlineInputBorder(),
                  ),
                  items: DayName.values
                      .map(
                        (d) => DropdownMenuItem(
                          value: d,
                          child: Text(d.name.toUpperCase()),
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
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Penagihan (1-31)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => _selectedDay = int.tryParse(val) ?? 1,
                ),

              if (_selectedType == TimeType.annual) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: _selectedMonth,
                  decoration: const InputDecoration(
                    labelText: 'Bulan Penagihan',
                    border: OutlineInputBorder(),
                  ),
                  items: List.generate(
                    12,
                    (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text('Bulan ${index + 1}'),
                    ),
                  ),
                  onChanged: (val) => setState(() => _selectedMonth = val!),
                ),
              ],

              const SizedBox(height: 32),
              CustomButton(
                title: 'Simpan Tagihan',
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
