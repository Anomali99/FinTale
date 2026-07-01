import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/constants/gamification_dict.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/enum_types.dart';
import '../../../core/utils/leveling_extension.dart';
import '../../../models/user_model.dart';

class ProfileCard extends StatelessWidget {
  final bool isRpg;
  final UserModel? user;
  final VoidCallback? editName;

  const ProfileCard({
    super.key,
    required this.user,
    required this.isRpg,
    this.editName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final String name = user?.name ?? 'Adventurer';
    final String? email = user?.email;
    final TitleType title = user?.title ?? TitleType.noviceSaver;
    final double xpPercentage = user?.progressPercentage ?? 0.0;
    final int targetXp = user?.requiredXp ?? 0;
    final int level = user?.level ?? 1;
    final int xp = user?.xp ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: colorScheme.primary.withOpacity(0.2),
                child: FaIcon(
                  FontAwesomeIcons.userAstronaut,
                  color: colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: editName,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 4,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Lv. $level - ${GamificationDict.getTitleByEnum(title).get(isRpg)}',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    if (user?.email != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        email ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'EXP',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.warning,
                ),
              ),
              Text(
                '$xp / $targetXp',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: xpPercentage,
              backgroundColor: theme.scaffoldBackgroundColor,
              color: AppColors.warning,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
