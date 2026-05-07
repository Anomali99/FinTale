import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/shared_dict.dart';
import '../../../models/bill_model.dart';
import '../../../models/debt_model.dart';
import '../../../widgets/custom_button.dart';

class AddDebtModal extends StatefulWidget {
  const AddDebtModal({super.key});

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
      if (_createBill) {
        bill = BillModel(
          title: 'Cicilan: ${_titleController.text.trim()}',
          amount: BigInt.parse(_installmentController.text.replaceAll('.', '')),
          type: _billFrequency,
          day: _billDay,
        );
      }

      DebtModel debt = DebtModel(
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
                'Tambah Hutang Baru',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Nama Hutang / Pinjaman',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty
                    ? SharedDict.requiredTitle
                    : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<DebtType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipe Hutang',
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
                      decoration: const InputDecoration(
                        labelText: 'Total Hutang',
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) =>
                          _onNumberChanged(_totalAmountController, val),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Wajib diisi' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _paidAmountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Sudah Dibayar',
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
                title: const Text(
                  'Buat Tagihan Rutin?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Aktifkan untuk memantau cicilan setiap periode secara otomatis.',
                ),
                value: _createBill,
                onChanged: (val) => setState(() => _createBill = val),
              ),

              if (_createBill) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _installmentController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Nominal Cicilan',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) =>
                      _onNumberChanged(_installmentController, val),
                  validator: (val) =>
                      _createBill && (val == null || val.isEmpty)
                      ? 'Wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<TimeType>(
                        initialValue: _billFrequency,
                        decoration: const InputDecoration(
                          labelText: 'Frekuensi',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: TimeType.monthly,
                            child: Text('Bulanan'),
                          ),
                          DropdownMenuItem(
                            value: TimeType.weekly,
                            child: Text('Mingguan'),
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
                              ? 'Tanggal'
                              : 'Hari ke-',
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
                title: 'Simpan Hutang',
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
