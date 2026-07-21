import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/settings_controller.dart';
import '../controllers/wallet_controller.dart';
import '../core/constants/ui_dict.dart';
import '../core/models/category_model.dart';
import '../core/utils/enum_types.dart';
import 'custom_button.dart';

class FilterFeatures {
  final bool date;
  final bool wallet;
  final bool type;
  final bool category;

  FilterFeatures({
    this.date = true,
    this.wallet = true,
    this.type = true,
    this.category = true,
  });
}

class FilterBottomSheet extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<TransactionType>? selectedTypes;
  final List<TransactionCategory>? selectedCategories;
  final List<int>? selectedWallets;
  final FilterFeatures? features;
  const FilterBottomSheet({
    super.key,
    this.startDate,
    this.endDate,
    this.selectedTypes,
    this.selectedCategories,
    this.selectedWallets,
    this.features,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  List<TransactionType> _selectedTypes = [];
  List<TransactionCategory> _selectedCategories = [];
  List<int> _selectedWallets = [];

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _selectedTypes = List.from(widget.selectedTypes ?? []);
    _selectedCategories = List.from(widget.selectedCategories ?? []);
    _selectedWallets = List.from(widget.selectedWallets ?? []);
  }

  void _pickDateRange() async {
    final colorScheme = Theme.of(context).colorScheme;

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
            colorScheme: colorScheme.copyWith(
              primary: colorScheme.primary,
              onPrimary: colorScheme.onPrimary,
              surface: colorScheme.surface,
              onSurface: colorScheme.onSurface,
            ),

            datePickerTheme: DatePickerThemeData(
              rangeSelectionBackgroundColor: colorScheme.primary.withOpacity(
                0.15,
              ),

              headerBackgroundColor: colorScheme.surfaceContainerHighest,
              headerForegroundColor: colorScheme.onSurface,
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
      "isReset": false,
      "startDate": _startDate,
      "endDate": _endDate,
      "selectedTypes": _selectedTypes,
      "selectedCategories": _selectedCategories,
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
    Navigator.pop(context, {"isReset": true});
  }

  @override
  Widget build(BuildContext context) {
    final walletController = context.read<WalletController>();
    final settingsController = context.read<SettingsController>();
    final colorScheme = Theme.of(context).colorScheme;
    final isRpg = settingsController.isRpgMode;
    final enableFeatures = widget.features ?? FilterFeatures();
    final wallets = walletController.wallets;
    String dateText = UiDict.setDate;
    if (_startDate != null && _endDate != null) {
      dateText =
          "${DateFormat('dd MMM yyyy').format(_startDate!)} - ${DateFormat('dd MMM yyyy').format(_endDate!)}";
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
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
                UiDict.transactionFilter,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
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
                    UiDict.reset,
                    style: TextStyle(
                      color: colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (enableFeatures.date) ...[
            Text(
              UiDict.rangeDate,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDateRange,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _startDate != null
                        ? colorScheme.primary
                        : colorScheme.onSurface.withOpacity(0.3),
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
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurface,
                        fontSize: 16,
                      ),
                    ),
                    Icon(
                      Icons.date_range,
                      color: _startDate != null
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (enableFeatures.type) ...[
                    Text(
                      UiDict.transactionType,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (var entry in TransactionType.values)
                      _buildTypeCheckbox(entry),
                    const SizedBox(height: 24),
                  ],

                  if (enableFeatures.wallet) ...[
                    Text(
                      UiDict.transactionMethode,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (wallets.isEmpty) ...[
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          UiDict.getEmptyDesc(UiDict.wallet),
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ] else ...[
                      for (var entry in wallets)
                        _buildWalletCheckbox(entry.name, entry.id ?? 0),
                    ],
                    const SizedBox(height: 24),
                  ],

                  if (enableFeatures.category) ...[
                    Text(
                      '${UiDict.category} ${UiDict.income.get(isRpg)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (var entry in TransactionCategory.incomeCategories)
                      _buildCategoryCheckbox(entry, isRpg),
                    const SizedBox(height: 24),
                    Text(
                      '${UiDict.category} ${UiDict.expense.get(isRpg)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (var entry in TransactionCategory.allExpenseCategories)
                      _buildCategoryCheckbox(entry, isRpg),
                    const SizedBox(height: 24),
                    Text(
                      '${UiDict.category} ${UiDict.menuInvest.get(isRpg)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (var entry in TransactionCategory.investCategories)
                      _buildCategoryCheckbox(entry, isRpg),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          CustomButton(
            title: UiDict.applyFilter,
            color: colorScheme.primary,
            onTap: _applyFilter,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCheckbox(TransactionType type) {
    final colorScheme = Theme.of(context).colorScheme;

    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: colorScheme.primary,
      checkColor: colorScheme.onPrimary,
      side: BorderSide(color: colorScheme.onSurfaceVariant, width: 1.5),
      title: Text(
        type.value,
        style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
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

  Widget _buildCategoryCheckbox(TransactionCategory category, bool isRpg) {
    final colorScheme = Theme.of(context).colorScheme;
    CategoryModel dict = category.categoryDict;

    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: colorScheme.primary,
      checkColor: colorScheme.onPrimary,
      side: BorderSide(color: colorScheme.onSurfaceVariant, width: 1.5),
      title: Text(
        dict.get(isRpg),
        style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
      ),
      value: _selectedCategories.contains(category),
      onChanged: (bool? value) {
        setState(() {
          if (value == true) {
            _selectedCategories.add(category);
          } else {
            _selectedCategories.remove(category);
          }
        });
      },
    );
  }

  Widget _buildWalletCheckbox(String title, int walletId) {
    final colorScheme = Theme.of(context).colorScheme;

    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: colorScheme.primary,
      checkColor: colorScheme.onPrimary,
      side: BorderSide(color: colorScheme.onSurfaceVariant, width: 1.5),
      title: Text(
        title,
        style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
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
