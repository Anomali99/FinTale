import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/wallet_controller.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/category_dict.dart';
import '../core/constants/shared_dict.dart';
import '../core/utils/currency_formatter.dart';
import '../models/transaction_detail_model.dart';
import '../models/transaction_model.dart';
import 'custom_button.dart';

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

class DailyExpense extends StatefulWidget {
  final bool isRpg;

  const DailyExpense({super.key, required this.isRpg});

  @override
  State<DailyExpense> createState() => _DailyExpenseState();
}

class _DailyExpenseState extends State<DailyExpense> {
  final _formKey = GlobalKey<FormState>();

  final _mainTitleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  int? _selectedWalletId;

  final List<ExpenseItemForm> _items = [];

  final List<TransactionCategory> _expenseCategories = [
    TransactionCategory.food,
    TransactionCategory.groceries,
    TransactionCategory.transport,
    TransactionCategory.entertainment,
    TransactionCategory.health,
    TransactionCategory.utilities,
  ];

  @override
  void initState() {
    super.initState();
    _addNewItem();
  }

  @override
  void dispose() {
    _mainTitleController.dispose();
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

  void _onAmountChanged(TextEditingController controller, String value) {
    String cleanText = value.replaceAll('.', '');

    if (cleanText.isEmpty) {
      controller.text = '';
      setState(() {});
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
    setState(() {});
  }

  BigInt get _totalAmount {
    BigInt total = BigInt.zero;
    for (var item in _items) {
      String cleanText = item.amountController.text.replaceAll('.', '');
      if (cleanText.isNotEmpty) {
        total += BigInt.parse(cleanText);
      }
    }
    return total;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedWalletId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sumber Dana (Dompet) harus dipilih!')),
        );
        return;
      }

      for (var i = 0; i < _items.length; i++) {
        if (_items[i].category == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Kategori pada Item #${i + 1} belum dipilih!'),
            ),
          );
          return;
        }
      }

      List<TransactionDetailModel> details = [];

      for (var item in _items) {
        BigInt amount = BigInt.parse(
          item.amountController.text.replaceAll('.', ''),
        );
        details.add(
          TransactionDetailModel(
            title: item.titleController.text.trim(),
            amount: amount,
            category: item.category!,
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
        walletId: _selectedWalletId,
        detailTransaction: details,
      );

      Navigator.pop(context, transaction);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletController = context.read<WalletController>();
    final wallets = walletController.wallets;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          widget.isRpg ? 'Catat Petualangan' : 'Catat Pengeluaran',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),

      bottomNavigationBar: _buildBottomBar(),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            Text(
              'Informasi Dasar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _mainTitleController,
              decoration: const InputDecoration(
                labelText: 'Judul Utama (Contoh: Belanja Bulanan)',
                border: OutlineInputBorder(),
              ),
              validator: (val) => val == null || val.trim().isEmpty
                  ? SharedDict.requiredTitle
                  : null,
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<int>(
              initialValue: _selectedWalletId,
              decoration: const InputDecoration(
                labelText: 'Sumber Dana (Gunakan Dompet)',
                border: OutlineInputBorder(),
              ),
              items: wallets.map((entry) {
                return DropdownMenuItem(
                  value: entry.id,
                  child: Text(entry.name),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedWalletId = val),
              validator: (val) =>
                  val == null ? SharedDict.requiredWallet : null,
            ),
            const SizedBox(height: 20),

            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Tanggal Petualangan',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  DateFormat('dd MMMM yyyy').format(_selectedDate),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
            ),

            const SizedBox(height: 32),
            const Divider(height: 1, color: Colors.white24),
            const SizedBox(height: 32),

            Text(
              'Rincian Barang',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),

            ..._items.asMap().entries.map((entry) {
              int index = entry.key;
              ExpenseItemForm item = entry.value;

              return Card(
                elevation: 0,
                color: AppColors.surfaceVariant.withOpacity(0.5),
                margin: const EdgeInsets.only(bottom: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.white10),
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
                              color: AppColors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Item #${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          if (_items.length > 1)
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                              ),
                              onPressed: () => _removeItem(index),
                              tooltip: 'Hapus Item',
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: item.titleController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Barang',
                          hintText: 'Contoh: Nasi Goreng',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Nama tidak boleh kosong'
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
                          labelText: 'Nominal Harga',
                          prefixText: 'Rp ',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) =>
                            _onAmountChanged(item.amountController, val),
                        validator: (val) {
                          if (val == null || val.isEmpty || val == '0')
                            return SharedDict.requiredAmount;
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<TransactionCategory>(
                        initialValue: item.category,
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                          border: OutlineInputBorder(),
                        ),
                        items: _expenseCategories.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(
                              CategoryDict.getByTransactionCategory(
                                cat,
                              ).get(widget.isRpg),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => item.category = val),
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
                  side: const BorderSide(
                    color: AppColors.primary,
                    style: BorderStyle.solid,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add, color: AppColors.primary),
                label: const Text(
                  'Tambah Barang Lagi',
                  style: TextStyle(
                    color: AppColors.primary,
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

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: 24 + MediaQuery.of(context).padding.bottom,
      ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Pembayaran',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              Text(
                CurrencyFormatter.convertToIdr(_totalAmount),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomButton(
            title: widget.isRpg ? 'Bayar Gold' : 'Simpan Pengeluaran',
            color: AppColors.error,
            onTap: _submitForm,
          ),
        ],
      ),
    );
  }
}
