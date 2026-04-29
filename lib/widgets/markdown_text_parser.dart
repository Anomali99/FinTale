import 'package:flutter/material.dart';

class MarkdownTextParser extends StatelessWidget {
  final String rawText;
  final TextStyle? style;
  final TextStyle? boldStyle;
  final TextStyle? italicStyle;

  const MarkdownTextParser({
    super.key,
    required this.rawText,
    this.style,
    this.boldStyle,
    this.italicStyle,
  });

  List<TextSpan> _parseNestedMarkdown(String text) {
    final List<TextSpan> spans = [];

    bool isBold = false;
    bool isItalic = false;
    StringBuffer buffer = StringBuffer();

    void flushBuffer() {
      if (buffer.isNotEmpty) {
        TextStyle spanStyle = const TextStyle();

        if (isBold) {
          spanStyle = spanStyle
              .merge(const TextStyle(fontWeight: FontWeight.bold))
              .merge(boldStyle);
        }
        if (isItalic) {
          spanStyle = spanStyle
              .merge(const TextStyle(fontStyle: FontStyle.italic))
              .merge(italicStyle);
        }

        spans.add(
          TextSpan(
            text: buffer.toString(),

            style: spanStyle == const TextStyle() ? null : spanStyle,
          ),
        );

        buffer.clear();
      }
    }

    for (int i = 0; i < text.length; i++) {
      if (i < text.length - 1 && text.substring(i, i + 2) == '**') {
        flushBuffer();
        isBold = !isBold;
        i++;
      } else if (text[i] == '`') {
        flushBuffer();
        isItalic = !isItalic;
      } else {
        buffer.write(text[i]);
      }
    }

    flushBuffer();

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: style ?? const TextStyle(fontSize: 16.0, color: Colors.black),
        children: _parseNestedMarkdown(rawText),
      ),
    );
  }
}
