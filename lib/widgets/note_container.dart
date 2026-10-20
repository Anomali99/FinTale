import 'package:flutter/material.dart';

import '../core/utils/color_extension.dart';
import 'markdown_text_parser.dart';

class NoteContainer extends StatelessWidget {
  final IconData icon;
  final Color? _color;
  final String text;
  const NoteContainer({
    super.key,
    required this.text,
    IconData? icon,
    Color? color,
  }) : icon = icon ?? Icons.info_outline,
       _color = color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = _color ?? Colors.blue.adapt(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: effectiveColor),
          const SizedBox(width: 8),
          Expanded(
            child: MarkdownTextParser(
              rawText: text,
              style: TextStyle(fontSize: 12, color: effectiveColor),
            ),
          ),
        ],
      ),
    );
  }
}
