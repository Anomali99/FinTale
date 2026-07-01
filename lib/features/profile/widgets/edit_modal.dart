import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/ui_dict.dart';
import '../../../core/utils/number_utils.dart';
import '../../../widgets/custom_button.dart';

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
      Navigator.pop(context, _controller.text.trim());
    }
  }

  void _onChanged(String value) {
    if (_controller.text != value && !widget.isCurrency) {
      _controller.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }

    NumberUtils.formatInput(_controller, value);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
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
                  if (value == null || value.trim().isEmpty) {
                    if (widget.isCurrency &&
                        !NumberUtils.isValidAmount(value ?? '')) {
                      return UiDict.requiredAmount;
                    } else {
                      return UiDict.requiredName;
                    }
                  }
                  return null;
                },
                onChanged: _onChanged,
              ),

              const SizedBox(height: 32),

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
