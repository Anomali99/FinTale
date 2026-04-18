import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dictionary.dart';

class MasterLogSheet extends StatelessWidget {
  final bool isRpg;

  const MasterLogSheet({super.key, required this.isRpg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppDictionary.manageBills.get(isRpg),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildAddButton(
            icon: AppDictionary.billsIcon.get(isRpg),
            title: AppDictionary.addRecurringBill.get(isRpg),
            color: Colors.blueAccent,
            onTap: () {
              /* TODO: Navigasi ke form tambah quest */
            },
          ),
          const SizedBox(height: 12),

          _buildAddButton(
            icon: AppDictionary.payIcon.get(isRpg),
            title: AppDictionary.addDebt.get(isRpg),
            color: AppColors.error,
            onTap: () {
              /* TODO: Navigasi ke form tambah hutang/boss */
            },
          ),

          const Divider(color: Colors.white10, height: 48),

          Text(
            isRpg ? 'Active Blueprints' : 'Active Templates',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
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
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton({
    required FaIconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
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
          children: [
            FaIcon(icon, color: color, size: 20),
            const SizedBox(width: 16),
            Text(
              title,
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
