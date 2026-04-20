import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dictionary.dart';
import 'bill_card.dart';

class BillsTab extends StatelessWidget {
  final bool isRpg;

  const BillsTab({super.key, required this.isRpg});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        Text(
          BillsDict.pending.get(isRpg).toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),

        BillCard(
          title: 'Listrik Rumah',
          dueDate: 'Due in 2 days',
          amount: 250000,
          icon: FontAwesomeIcons.bolt,
          isUrgent: true,
          isCleared: false,
          isRpg: isRpg,
        ),

        BillCard(
          title: 'Cicilan KPR Bulan ke-12',
          dueDate: 'Due in 15 days',
          amount: 1500000,
          icon: FontAwesomeIcons.houseUser,
          isUrgent: false,
          isCleared: false,
          isRpg: isRpg,
        ),

        const SizedBox(height: 32),

        Row(
          children: [
            const Expanded(child: Divider(color: Colors.white10)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                BillsDict.paid.get(isRpg).toUpperCase(),
                style: const TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Expanded(child: Divider(color: Colors.white10)),
          ],
        ),
        const SizedBox(height: 12),

        BillCard(
          title: 'Internet WiFi',
          dueDate: 'Paid on 2 May',
          amount: 300000,
          icon: FontAwesomeIcons.wifi,
          isUrgent: false,
          isCleared: true,
          isRpg: isRpg,
        ),

        const SizedBox(height: 100),
      ],
    );
  }
}
