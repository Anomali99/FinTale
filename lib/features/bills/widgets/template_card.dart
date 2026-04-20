import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/constants/app_colors.dart';

class TemplateCard extends StatelessWidget {
  const TemplateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.surfaceVariant,
              child: FaIcon(
                FontAwesomeIcons.bolt,
                size: 16,
                color: Colors.yellow,
              ),
            ),
            title: const Text('Listrik Bulanan'),
            subtitle: const Text('Setiap tgl 1'),
            trailing: const Icon(
              Icons.edit,
              size: 16,
              color: AppColors.textSecondary,
            ),
            onTap: () {
              /* TODO: Edit Master */
            },
          );
  }
}