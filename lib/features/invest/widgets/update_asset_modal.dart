import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/shared_dict.dart';
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
  @override
  void initState() {
    super.initState();

    _nameController.text = widget.asset.name;
    _unitNameController.text = widget.asset.unitName;

    _valueController.text = _formatNumber(widget.asset.value.toString());
    _isDevidenActive = widget.asset.hasDividend;
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
      BigInt newValue = BigInt.parse(_valueController.text.replaceAll('.', ''));

      AssetsModel updatedAsset = AssetsModel(
        id: widget.asset.id,
        name: _nameController.text.trim(),
        type: widget.asset.type,
        category: widget.asset.category,
        unitName: _unitNameController.text.trim(),
        invested: widget.asset.invested,
        hasDividend: _isDevidenActive,
        value: newValue,
        unit: widget.asset.unit,
      );

      Navigator.pop(context, updatedAsset);
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
                'Perbarui Data Aset',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Aset',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? SharedDict.requiredTitle
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
                      decoration: const InputDecoration(
                        labelText: 'Total Harga Pasar Saat Ini',
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: _onNumberChanged,
                      validator: (val) => val == null || val.isEmpty
                          ? 'Nilai pasar tidak boleh kosong'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _unitNameController,
                      decoration: const InputDecoration(
                        labelText: 'Satuan',
                        border: OutlineInputBorder(),
                        hintText: 'Misal: Lembar, Unit, Lot, Gram',
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Satuan wajib diisi'
                          : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              NoteContainer(
                text:
                    'Memperbarui Total Harga Pasar tidak akan mengubah catatan modal awal (Invested) yang sudah Anda keluarkan. Ini murni untuk memantau nilai aset Anda saat ini.',
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Aset Menghasilkan Dividen/Bunga?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Aktifkan jika instrumen ini memberikan imbal hasil rutin (seperti dividen saham atau kupon obligasi) yang nantinya dapat Anda klaim ke dompet.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                value: _isDevidenActive,
                onChanged: (val) => setState(() => _isDevidenActive = val),
              ),

              const SizedBox(height: 16),

              CustomButton(
                title: 'Simpan Perubahan',
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
