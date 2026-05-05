import 'package:flutter/material.dart';

import 'markdown_text_parser.dart';

class NoteContainer extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const NoteContainer({
    super.key,
    required this.text,
    IconData? icon,
    Color? color,
  }) : icon = icon ?? Icons.info_outline,
       color = color ?? Colors.blue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: MarkdownTextParser(
              rawText: text,
              style: TextStyle(fontSize: 12, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
