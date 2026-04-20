import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'debts_card.dart';

class DebtsTab extends StatelessWidget {
  final bool isRpg;

  const DebtsTab({super.key, required this.isRpg});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        DebtsCard(
          bossName: 'KPR Bank BCA',
          bossLevel: 'Lv. 99',
          currentHp: 200000000,
          maxHp: 300000000,
          icon: FontAwesomeIcons.buildingColumns,
          isRpg: isRpg,
        ),
        DebtsCard(
          bossName: 'Pinjaman Teman (Rio)',
          bossLevel: 'Lv. 10',
          currentHp: 1500000,
          maxHp: 5000000,
          icon: FontAwesomeIcons.handshake,
          isRpg: isRpg,
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}
