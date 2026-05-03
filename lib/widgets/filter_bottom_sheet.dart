import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/wallet_controller.dart';
import '../core/constants/app_colors.dart';
import '../models/transaction_model.dart';
import 'custom_button.dart';

class FilterBottomSheet extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<TransactionType>? selectedTypes;
  final List<int>? selectedWallets;
  const FilterBottomSheet({
    super.key,
    this.startDate,
    this.endDate,
    this.selectedTypes,
    this.selectedWallets,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  List<TransactionType> _selectedTypes = [];
  List<int> _selectedWallets = [];

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _selectedTypes = List.from(widget.selectedTypes ?? []);
    _selectedWallets = List.from(widget.selectedWallets ?? []);
  }

  void _pickDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.black,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),

            datePickerTheme: DatePickerThemeData(
              rangeSelectionBackgroundColor: AppColors.primary.withOpacity(
                0.15,
              ),

              headerBackgroundColor: AppColors.surfaceVariant,
              headerForegroundColor: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _applyFilter() {
    Navigator.pop(context, {
      "startDate": _startDate,
      "endDate": _endDate,
      "selectedTypes": _selectedTypes,
      "selectedWallets": _selectedWallets,
    });
  }

  void _resetFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedTypes.clear();
      _selectedWallets.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final walletController = context.read<WalletController>();
    final wallets = walletController.wallets;
    String dateText = "Pilih tanggal awal dan akhir";
    if (_startDate != null && _endDate != null) {
      dateText =
          "${DateFormat('dd MMM yyyy').format(_startDate!)} - ${DateFormat('dd MMM yyyy').format(_endDate!)}";
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Transaksi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              InkWell(
                onTap: _resetFilter,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    'Reset',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            'Rentang Tanggal',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickDateRange,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _startDate != null
                      ? AppColors.primary
                      : Colors.white30,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateText,
                    style: TextStyle(
                      color: _startDate == null
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                  Icon(
                    Icons.date_range,
                    color: _startDate != null
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tipe transaksi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTypeCheckbox('Pemasukan', TransactionType.income),
                  _buildTypeCheckbox('Pengeluaran', TransactionType.expense),
                  _buildTypeCheckbox('Transfer', TransactionType.transfer),
                  _buildTypeCheckbox('Pembayaran Hutang', TransactionType.debt),

                  const SizedBox(height: 24),

                  const Text(
                    'Metode transaksi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (wallets.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Belum ada dompet",
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  for (var entry in wallets)
                    _buildWalletCheckbox(entry.name, entry.id ?? 0),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          CustomButton(
            title: 'Terapkan Filter',
            color: AppColors.primary,
            onTap: _applyFilter,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCheckbox(String title, TransactionType type) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: AppColors.primary,
      checkColor: Colors.black,
      side: const BorderSide(color: Colors.white54, width: 1.5),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      ),
      value: _selectedTypes.contains(type),
      onChanged: (bool? value) {
        setState(() {
          if (value == true) {
            _selectedTypes.add(type);
          } else {
            _selectedTypes.remove(type);
          }
        });
      },
    );
  }

  Widget _buildWalletCheckbox(String title, int walletId) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: AppColors.primary,
      checkColor: Colors.black,
      side: const BorderSide(color: Colors.white54, width: 1.5),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      ),
      value: _selectedWallets.contains(walletId),
      onChanged: (bool? value) {
        setState(() {
          if (value == true) {
            _selectedWallets.add(walletId);
          } else {
            _selectedWallets.remove(walletId);
          }
        });
      },
    );
  }
}
