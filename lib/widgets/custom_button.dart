import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomButton extends StatelessWidget {
  final FaIconData? icon;
  final String? title;
  final Color color;
  final VoidCallback? onTap;

  const CustomButton({
    super.key,
    required this.color,
    this.onTap,
    this.title,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) FaIcon(icon, color: color, size: 20),

            if (icon != null && title != null) const SizedBox(width: 16),

            if (title != null)
              Text(
                title ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
