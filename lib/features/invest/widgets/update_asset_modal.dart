import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/settings_controller.dart';
import '../../../core/constants/screen_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/utils/number_utils.dart';
import '../../../models/assets_model.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/note_container.dart';

class UpdateAssetModal extends StatefulWidget {
  final AssetsModel asset;

  const UpdateAssetModal({super.key, required this.asset});

  @override
  State<UpdateAssetModal> createState() => _UpdateAssetModalState();
}

class _UpdateAssetModalState extends State<UpdateAssetModal> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _unitNameController = TextEditingController();
  final _valueController = TextEditingController();
  bool _isDevidenActive = false;
  bool _isEmergencyActive = false;

  @override
  void initState() {
    super.initState();

    _nameController.text = widget.asset.name;
    _unitNameController.text = widget.asset.unitName;

    Decimal pricePerUnit = Decimal.zero;
    if (widget.asset.unit > Decimal.zero) {
      double priceDouble =
          widget.asset.value.toDouble() / widget.asset.unit.toDouble();
      pricePerUnit = Decimal.parse(priceDouble.toStringAsFixed(0));
    }

    _valueController.text = NumberUtils.formatNumber(
      pricePerUnit,
      decimalDigits: 0,
    );
    _isDevidenActive = widget.asset.hasDividend;
    _isEmergencyActive = widget.asset.isEmergency;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitNameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Decimal price = NumberUtils.parseToDecimal(_valueController.text);
      Decimal total = widget.asset.unit * price;

      AssetsModel updatedAsset = AssetsModel(
        id: widget.asset.id,
        name: _nameController.text.trim(),
        type: widget.asset.type,
        category: widget.asset.category,
        unitName: _unitNameController.text.trim(),
        invested: widget.asset.invested,
        hasDividend: _isDevidenActive,
        isEmergency: _isEmergencyActive,
        value: total,
        unit: widget.asset.unit,
      );

      Navigator.pop(context, updatedAsset);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isRpg = context.read<SettingsController>().isRpgMode;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: 24 + bottomInset,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
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
                    color: colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Text(
                ScreenDict.investUpdateAsset.get(isRpg),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: UiDict.name,
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? UiDict.requiredName
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _valueController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: ScreenDict.getInvestPricePerUnit(
                          _unitNameController.text.trim(),
                        ),
                        prefixText: 'Rp ',
                        border: const OutlineInputBorder(),
                      ),

                      onChanged: (val) => NumberUtils.formatInput(
                        _valueController,
                        val,
                        isDecimal: true,
                      ),
                      validator: (val) =>
                          val == null || !NumberUtils.isValidAmount(val)
                          ? UiDict.requiredPrice
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _unitNameController,
                      decoration: InputDecoration(
                        labelText: ScreenDict.investUnit.get(isRpg),
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (val) => setState(() {}),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? ScreenDict.investUnitRequired.get(isRpg)
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              NoteContainer(
                text: ScreenDict.getInvestUpdateDesc(isRpg: isRpg),
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  ScreenDict.getDevidenCheck(isRpg: isRpg),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  ScreenDict.getDevidenCheckDesc(isRpg: isRpg),
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                value: _isDevidenActive,
                onChanged: (val) => setState(() => _isDevidenActive = val),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  ScreenDict.getEmergencyCheck(isRpg: isRpg),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  ScreenDict.getEmergencyCheckDesc(isRpg: isRpg),
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                value: _isEmergencyActive,
                onChanged: (val) => setState(() => _isEmergencyActive = val),
              ),
              const SizedBox(height: 16),

              CustomButton(
                title: UiDict.saveChanges,
                color: colorScheme.primary,
                onTap: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
