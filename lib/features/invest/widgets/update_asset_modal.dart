import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../controllers/settings_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/screen_dict.dart';
import '../../../core/constants/ui_dict.dart';
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

    BigInt pricePerUnit = BigInt.zero;
    if (widget.asset.unit.toDouble() > 0) {
      pricePerUnit = BigInt.from(
        (widget.asset.value.toDouble() / widget.asset.unit.toDouble()).round(),
      );
    }

    _valueController.text = _formatNumber(pricePerUnit.toString());
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

  String _formatNumber(String value) {
    BigInt currentValue = BigInt.tryParse(value) ?? BigInt.zero;
    return currentValue.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void _onNumberChanged(String value) {
    String cleanText = value.replaceAll('.', '');

    if (cleanText.isEmpty) {
      _valueController.text = '';
      return;
    }

    BigInt currentValue = BigInt.tryParse(cleanText) ?? BigInt.zero;
    String formattedText = currentValue.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );

    if (_valueController.text != formattedText) {
      _valueController.value = TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      BigInt price = BigInt.parse(_valueController.text.replaceAll('.', ''));
      BigInt total = BigInt.from(
        (widget.asset.unit.toDouble() * price.toDouble()).round(),
      );

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
                ScreenDict.investUpdateAsset.get(isRpg),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
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
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: ScreenDict.getInvestPricePerUnit(
                          _unitNameController.text,
                        ),
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: _onNumberChanged,
                      validator: (val) => val == null || val.isEmpty
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
                        border: OutlineInputBorder(),
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
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  ScreenDict.getDevidenCheck(isRpg: isRpg),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  ScreenDict.getDevidenCheckDesc(isRpg: isRpg),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                value: _isDevidenActive,
                onChanged: (val) => setState(() => _isDevidenActive = val),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  ScreenDict.getEmergencyCheck(isRpg: isRpg),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  ScreenDict.getEmergencyCheckDesc(isRpg: isRpg),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                value: _isEmergencyActive,
                onChanged: (val) => setState(() => _isEmergencyActive = val),
              ),

              const SizedBox(height: 16),

              CustomButton(
                title: UiDict.saveChanges,
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
