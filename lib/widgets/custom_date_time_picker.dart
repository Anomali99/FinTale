import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class CustomDateTimePicker extends StatelessWidget {
  final DateTime initialDate;
  final String? label;
  final ValueChanged<DateTime> onChanged;

  const CustomDateTimePicker({
    super.key,
    required this.initialDate,
    required this.onChanged,
    this.label,
  });

  Future<void> _pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      if (!context.mounted) return;

      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (pickedTime != null) {
        onChanged(
          DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          ),
        );
      } else {
        onChanged(
          DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            initialDate.hour,
            initialDate.minute,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _pickDate(context),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
              ),
              child: Text(
                DateFormat('dd MMMM yyyy • HH:mm').format(initialDate),
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 51,
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.onSurface.withOpacity(0.38)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: IconButton(
            onPressed: () => onChanged(DateTime.now()),
            icon: FaIcon(
              FontAwesomeIcons.arrowRotateLeft,
              color: colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
