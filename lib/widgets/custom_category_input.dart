import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../controllers/settings_controller.dart';
import '../core/constants/ui_dict.dart';
import '../core/utils/enum_types.dart';

enum CategoryType { expense, allExpense, income, invest, transfer }

class CustomCategoryInput extends FormField<TransactionCategory> {
  final String label;
  final String hintText;
  final CategoryType type;
  final List<TransactionCategory>? categories;
  final bool? isRpg;
  final ValueChanged<TransactionCategory>? onChanged;

  CustomCategoryInput({
    super.key,
    this.type = CategoryType.expense,
    this.categories,
    TransactionCategory? selectedCategory,
    this.onChanged,
    this.isRpg,
    this.label = UiDict.category,
    this.hintText = UiDict.selectCategory,
    super.validator,
    super.enabled = true,
    super.autovalidateMode,
  }) : super(
         initialValue: selectedCategory,
         builder: (FormFieldState<TransactionCategory> state) {
           return _CustomCategoryInputField(
             state: state,
             label: label,
             hintText: hintText,
             type: type,
             categories: categories,
             isRpg: isRpg,
             enabled: enabled,
             onChanged: onChanged,
           );
         },
       );

  static Future<TransactionCategory?> showPicker(
    BuildContext context, {
    required List<TransactionCategory> categories,
    TransactionCategory? selectedCategory,
    bool? isRpg,
    String title = UiDict.category,
  }) async {
    final colorScheme = Theme.of(context).colorScheme;
    final rpg = isRpg ?? context.read<SettingsController>().isRpgMode;

    return showModalBottomSheet<TransactionCategory>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.75,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.4,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
                Divider(color: colorScheme.onSurface.withValues(alpha: 0.1)),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: categories.length,
                    itemBuilder: (ctx, index) {
                      final cat = categories[index];
                      final model = cat.categoryDict;
                      final isSelected = selectedCategory == cat;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: model
                              .getColor(ctx)
                              .withValues(alpha: 0.15),
                          child: FaIcon(
                            model.icon(rpg),
                            color: model.getColor(ctx),
                            size: 18,
                          ),
                        ),
                        title: Text(
                          model.get(rpg),
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check, color: colorScheme.primary)
                            : null,
                        onTap: () => Navigator.pop(ctx, cat),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CustomCategoryInputField extends StatelessWidget {
  final FormFieldState<TransactionCategory> state;
  final String label;
  final String hintText;
  final CategoryType type;
  final List<TransactionCategory>? categories;
  final bool? isRpg;
  final bool enabled;
  final ValueChanged<TransactionCategory>? onChanged;

  const _CustomCategoryInputField({
    required this.state,
    required this.label,
    required this.hintText,
    required this.type,
    required this.categories,
    required this.isRpg,
    required this.enabled,
    required this.onChanged,
  });

  List<TransactionCategory> _getCategories() {
    if (categories != null && categories!.isNotEmpty) {
      return categories!;
    }
    switch (type) {
      case CategoryType.transfer:
        return TransactionCategory.transferCategories;
      case CategoryType.income:
        return TransactionCategory.incomeCategories;
      case CategoryType.invest:
        return TransactionCategory.investCategories;
      case CategoryType.allExpense:
        return TransactionCategory.allExpenseCategories;
      case CategoryType.expense:
        return TransactionCategory.expenseCategories;
    }
  }

  Future<void> _handleTap(BuildContext context) async {
    final list = _getCategories();
    final selected = await CustomCategoryInput.showPicker(
      context,
      categories: list,
      selectedCategory: state.value,
      isRpg: isRpg,
      title: label,
    );

    if (selected != null) {
      state.didChange(selected);
      onChanged?.call(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rpg = isRpg ?? context.read<SettingsController>().isRpgMode;
    final selected = state.value;

    return InkWell(
      onTap: enabled ? () => _handleTap(context) : null,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          errorText: state.errorText,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (selected != null)
              Expanded(
                child: Row(
                  children: [
                    FaIcon(
                      selected.categoryDict.icon(rpg),
                      color: selected.categoryDict.getColor(context),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selected.categoryDict.get(rpg),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )
            else
              Text(
                hintText,
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
