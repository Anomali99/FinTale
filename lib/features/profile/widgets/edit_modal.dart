import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../widgets/custom_button.dart';

extension StringCapitalize on String {
  String capitalize() {
    if (isEmpty) return this;

    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}

class EditModal extends StatefulWidget {
  final String title;
  final String? fieldTitle;
  final String? defaultValue;
  final bool isCurrency;
  const EditModal({
    super.key,
    required this.title,
    this.fieldTitle,
    this.defaultValue,
    bool? isCurrency,
  }) : isCurrency = isCurrency ?? false;

  @override
  State<EditModal> createState() => _EditModalState();
}

class _EditModalState extends State<EditModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();

  String get _cleanText {
    String text = _controller.text.trim();
    if (!widget.isCurrency) return text;
    return text.replaceAll('.', '');
  }

  @override
  void initState() {
    super.initState();

    if (widget.defaultValue != null) {
      if (widget.isCurrency) {
        _onChanged(widget.defaultValue!);
      } else {
        _controller.text = widget.defaultValue!;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, _cleanText);
    }
  }

  void _onChanged(String value) {
    if (_controller.text != value && !widget.isCurrency) {
      _controller.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }

    String cleanText = value.replaceAll('.', '');
    if (cleanText.isEmpty) {
      _controller.text = '';
      return;
    }

    String formattedText = BigInt.parse(cleanText).toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );

    if (_controller.text != formattedText) {
      _controller.value = TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
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
              Text(
                widget.title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _controller,
                keyboardType: widget.isCurrency ? TextInputType.number : null,
                inputFormatters: widget.isCurrency
                    ? [FilteringTextInputFormatter.digitsOnly]
                    : null,
                decoration: InputDecoration(
                  labelText: widget.fieldTitle ?? widget.title,
                  prefixText: widget.isCurrency ? 'Rp ' : null,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty ||
                      (widget.isCurrency &&
                          value.trim().replaceAll('.', '').isEmpty)) {
                    return '${widget.fieldTitle ?? widget.title} is required.'
                        .capitalize();
                  }
                  return null;
                },
                onChanged: _onChanged,
              ),

              const SizedBox(height: 32),

              CustomButton(
                title: 'Save Changes',
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
