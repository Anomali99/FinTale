import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../core/constants/app_colors.dart';

class BottomSheetChild {
  final String title;
  final String? subtitle;
  final Color color;
  final FaIconData icon;
  final GestureTapCallback onTap;

  const BottomSheetChild({
    required this.title,
    required this.color,
    required this.icon,
    required this.onTap,
    this.subtitle,
  });
}

class CustomBottomSheet extends StatelessWidget {
  final List<BottomSheetChild> children;
  final String? title;
  final bool hideDriver;

  const CustomBottomSheet({
    super.key,
    this.title,
    this.hideDriver = false,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (title != null) ...[
            const SizedBox(height: 16),
            Text(
              title ?? '',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ] else
            const SizedBox(height: 24),

          for (BottomSheetChild data in children) ...[
            if (!hideDriver) const Divider(color: Colors.white10),

            ListTile(
              leading: CircleAvatar(
                backgroundColor: data.color.withOpacity(0.2),
                child: FaIcon(data.icon, color: data.color, size: 18),
              ),
              title: Text(
                data.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: data.subtitle != null
                  ? Text(data.subtitle ?? '')
                  : null,
              onTap: data.onTap,
            ),
          ],

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
