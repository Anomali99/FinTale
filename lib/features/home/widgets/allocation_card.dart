import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/constants/gamification_dict.dart';
import '../../../core/constants/screen_dict.dart';
import '../../../core/models/category_model.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/user_model.dart';

class AllocationCard extends StatelessWidget {
  final AllocationModel allocation;
  final VoidCallback? onTap;
  final bool isRpg;

  const AllocationCard({
    super.key,
    required this.allocation,
    required this.isRpg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final CategoryModel sector = GamificationDict.getSkillByEnum(
      allocation.sector,
    );
    final CategoryModel? subSector = allocation.subSector != null
        ? GamificationDict.getSkillByEnum(allocation.subSector!)
        : null;
    final Color sectorColor = subSector?.color ?? sector.color!;
    final String sectorName = sector.get(isRpg);
    final String? subSectorName = subSector?.get(isRpg);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: sectorColor.withOpacity(0.2), width: 1.5),
      ),

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: sectorColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: FaIcon(
                  (subSector ?? sector).icon(isRpg),
                  color: sectorColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sectorName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subSectorName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subSectorName,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    ScreenDict.homePending.get(isRpg),
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.convertToIdr(allocation.amount),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
