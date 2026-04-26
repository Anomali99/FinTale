import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/title_dict.dart';
import '../../../models/user_model.dart';

class ProfilCard extends StatelessWidget {
  final bool isRpg;
  final UserModel user;
  final VoidCallback? editName;
  final int _targetXp = 5000;

  const ProfilCard({
    super.key,
    required this.user,
    required this.isRpg,
    this.editName,
  });

  @override
  Widget build(BuildContext context) {
    final double xpPercentage = _targetXp > 0
        ? (user.xp / _targetXp).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: const FaIcon(
                  FontAwesomeIcons.userAstronaut,
                  color: AppColors.primary,
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
                            user.name,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: editName,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.only(left: 8),
                        ),
                      ],
                    ),
                    Text(
                      'Lv. ${user.level} - ${TitleDict.getByEnum(user.title).get(isRpg)}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary.withOpacity(0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
                '${user.xp} / $_targetXp',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: xpPercentage,
              backgroundColor: AppColors.background,
              color: AppColors.warning,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
