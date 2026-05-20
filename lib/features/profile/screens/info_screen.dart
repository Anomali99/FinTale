import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/category_dict.dart';
import '../../../core/constants/gamification_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/models/mission_model.dart';
import '../../../core/utils/enum_types.dart';
import '../../../widgets/markdown_text_parser.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          UiDict.information,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildSectionHeader(GamificationDict.missionDaily),
          const SizedBox(height: 16),
          for (MissionModel mission in GamificationDict.allMission)
            _buildMissionCard(mission: mission),

          const SizedBox(height: 32),

          _buildSectionHeader(GamificationDict.titleSystem),
          const SizedBox(height: 16),
          _buildTitleTable(),

          const SizedBox(height: 32),

          _buildSectionHeader(GamificationDict.allocationGuide),
          const SizedBox(height: 16),

          _buildLevelTierCard(
            level: '1 - 10',
            title: GamificationDict.titleNovice.get(false),
            skills: {
              SectorType.living: {
                "value": "55% ± 5%",
                "sub": {
                  SubSectorType.essentials: "DEFAULT",
                  SubSectorType.dreamFund: "OPTIONAL",
                },
              },
              SectorType.payDebt: {"value": "25% ± 3%", "sub": null},
              SectorType.emergency: {
                "value": "20% ± 3%",
                "sub": {SubSectorType.lowRisk: "20% ± 3%"},
              },
              SectorType.investment: {
                "value": null,
                "sub": {
                  SubSectorType.lowRisk: null,
                  SubSectorType.mediumRisk: null,
                  SubSectorType.highRisk: null,
                },
              },
            },
          ),

          _buildLevelTierCard(
            level: '11 - 20',
            title: GamificationDict.titleSmart.get(false),
            skills: {
              SectorType.living: {
                "value": "50% ± 5%",
                "sub": {
                  SubSectorType.essentials: "DEFAULT",
                  SubSectorType.dreamFund: "OPTIONAL",
                },
              },
              SectorType.payDebt: {"value": "20% ± 3%", "sub": null},
              SectorType.emergency: {
                "value": "20% ± 4%",
                "sub": {SubSectorType.lowRisk: "20% ± 4%"},
              },
              SectorType.investment: {
                "value": "10% ± 2%",
                "sub": {
                  SubSectorType.lowRisk: "OPTIONAL",
                  SubSectorType.mediumRisk: "10% ± 2%",
                  SubSectorType.highRisk: null,
                },
              },
            },
          ),

          _buildLevelTierCard(
            level: '21 - 30',
            title: GamificationDict.titleWise.get(false),
            skills: {
              SectorType.living: {
                "value": "45% ± 7%",
                "sub": {
                  SubSectorType.essentials: "DEFAULT",
                  SubSectorType.dreamFund: "OPTIONAL",
                },
              },
              SectorType.payDebt: {"value": "15% ± 5%", "sub": null},
              SectorType.emergency: {
                "value": "20% ± 4%",
                "sub": {SubSectorType.lowRisk: "20% ± 4%"},
              },
              SectorType.investment: {
                "value": "20% ± 7%",
                "sub": {
                  SubSectorType.lowRisk: "OPTIONAL",
                  SubSectorType.mediumRisk: "15% ± 5%",
                  SubSectorType.highRisk: "5% ± 2%",
                },
              },
            },
          ),

          _buildLevelTierCard(
            level: '31 - 40',
            title: GamificationDict.titleWealth.get(false),
            skills: {
              SectorType.living: {
                "value": "40% ± 7%",
                "sub": {
                  SubSectorType.essentials: "DEFAULT",
                  SubSectorType.dreamFund: "OPTIONAL",
                },
              },
              SectorType.payDebt: {"value": "10% ± 5%", "sub": null},
              SectorType.emergency: {
                "value": "25% ± 5%",
                "sub": {SubSectorType.lowRisk: "25% ± 5%"},
              },
              SectorType.investment: {
                "value": "25% ± 10%",
                "sub": {
                  SubSectorType.lowRisk: "OPTIONAL",
                  SubSectorType.mediumRisk: "15% ± 5%",
                  SubSectorType.highRisk: "10% ± 5%",
                },
              },
            },
          ),

          _buildLevelTierCard(
            level: '41 - 49',
            title: GamificationDict.titleWealth.get(false),
            skills: {
              SectorType.living: {
                "value": "35% ± 10%",
                "sub": {
                  SubSectorType.essentials: "DEFAULT",
                  SubSectorType.dreamFund: "OPTIONAL",
                },
              },
              SectorType.payDebt: {"value": "5% ± 5%", "sub": null},
              SectorType.emergency: {
                "value": "30% ± 10%",
                "sub": {SubSectorType.lowRisk: "30% ± 10%"},
              },
              SectorType.investment: {
                "value": "30% ± 10%",
                "sub": {
                  SubSectorType.lowRisk: "OPTIONAL",
                  SubSectorType.mediumRisk: "15% ± 5%",
                  SubSectorType.highRisk: "15% ± 5%",
                },
              },
            },
          ),

          _buildLevelTierCard(
            level: '50+',
            title: GamificationDict.titleMaster.get(false),
            skills: {
              SectorType.living: {
                "value": "CUSTOM",
                "sub": {
                  SubSectorType.essentials: "CUSTOM",
                  SubSectorType.dreamFund: "CUSTOM",
                },
              },
              SectorType.payDebt: {"value": "CUSTOM", "sub": null},
              SectorType.emergency: {
                "value": "CUSTOM",
                "sub": {SubSectorType.lowRisk: "CUSTOM"},
              },
              SectorType.investment: {
                "value": "CUSTOM",
                "sub": {
                  SubSectorType.lowRisk: "CUSTOM",
                  SubSectorType.mediumRisk: "CUSTOM",
                  SubSectorType.highRisk: "CUSTOM",
                },
              },
            },
          ),

          const SizedBox(height: 24),

          _buildSectionHeader(GamificationDict.allocationRules),
          const SizedBox(height: 12),
          _buildMechanismCard(
            GamificationDict.missionNote1Title,
            GamificationDict.missionNote1,
            icon: FontAwesomeIcons.arrowsDownToLine,
          ),
          _buildMechanismCard(
            GamificationDict.missionNote2Title,
            GamificationDict.missionNote2,
            icon: FontAwesomeIcons.handHoldingHeart,
          ),
          _buildMechanismCard(
            GamificationDict.missionNote3Title,
            GamificationDict.missionNote3,
            icon: FontAwesomeIcons.fire,
            color: Colors.orange,
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildLevelTierCard({
    required String level,
    required String title,
    required Map<SectorType, dynamic> skills,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lv. $level',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStatRow(
                  GamificationDict.skillDaily.icon(false),
                  GamificationDict.skillDaily.get(false),
                  skills[SectorType.living]['value'],
                  GamificationDict.skillDaily.color ?? Colors.blueAccent,
                ),
                _buildSubStatRow(
                  '- ${GamificationDict.skillRoutine.get(false)}',
                  skills[SectorType.living]['sub'][SubSectorType.essentials],
                ),
                _buildSubStatRow(
                  '- ${GamificationDict.skillDream.get(false)}',
                  skills[SectorType.living]['sub'][SubSectorType.dreamFund],
                ),
                const SizedBox(height: 12),

                _buildStatRow(
                  GamificationDict.skillDebt.icon(false),
                  GamificationDict.skillDebt.get(false),
                  skills[SectorType.payDebt]['value'],
                  GamificationDict.skillDebt.color ?? Colors.redAccent,
                ),
                const SizedBox(height: 12),

                _buildStatRow(
                  GamificationDict.skillInvestment.icon(false),
                  GamificationDict.skillInvestment.get(false),
                  skills[SectorType.emergency]['value'],
                  GamificationDict.skillInvestment.color ?? Colors.greenAccent,
                ),
                _buildSubStatRow(
                  '- ${CategoryDict.lowRisk.get(false)}',
                  skills[SectorType.emergency]['sub'][SubSectorType.lowRisk],
                ),
                const SizedBox(height: 12),

                _buildStatRow(
                  GamificationDict.skillInvestment.icon(false),
                  GamificationDict.skillInvestment.get(false),
                  skills[SectorType.investment]['value'],
                  GamificationDict.skillInvestment.color ?? Colors.purpleAccent,
                ),

                _buildSubStatRow(
                  '- ${CategoryDict.lowRisk.get(false)}',
                  skills[SectorType.investment]['sub'][SubSectorType.lowRisk],
                ),
                _buildSubStatRow(
                  '- ${CategoryDict.mediumRisk.get(false)}',
                  skills[SectorType.investment]['sub'][SubSectorType
                      .mediumRisk],
                ),
                _buildSubStatRow(
                  '- ${CategoryDict.highRisk.get(false)}',
                  skills[SectorType.investment]['sub'][SubSectorType.highRisk],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    FaIconData icon,
    String label,
    String? value,
    Color color,
  ) {
    bool isLocked = value == null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            FaIcon(icon, size: 16, color: isLocked ? Colors.grey : color),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isLocked ? Colors.grey : Colors.white,
              ),
            ),
          ],
        ),
        Text(
          isLocked ? 'LOCKED' : value,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: isLocked ? Colors.grey : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSubStatRow(String text, String? value) {
    bool isLocked = value == null;
    return Padding(
      padding: const EdgeInsets.only(left: 28, top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: isLocked ? Colors.grey : Colors.grey.shade500,
            ),
          ),
          Text(
            isLocked ? 'LOCKED' : value,
            style: TextStyle(
              fontSize: 11,
              color: isLocked ? Colors.grey : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard({required MissionModel mission}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: mission.color.withOpacity(0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: FaIcon(
                mission.icon(false),
                size: 80,
                color: mission.color.withOpacity(0.05),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          FaIcon(
                            mission.icon(false),
                            size: 18,
                            color: mission.color,
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 175,
                            child: Text(
                              mission.get(false),
                              maxLines: 2,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: mission.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          mission.frequency,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: mission.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mission.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Limit: ${mission.limit}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        mission.xp,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.orangeAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleTable() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
          },
          children: [
            _buildTableRow(['Level', 'RPG', 'Standar'], isHeader: true),
            _buildTableRow([
              '1 - 10',
              GamificationDict.titleNovice.get(true),
              GamificationDict.titleNovice.get(false),
            ]),
            _buildTableRow([
              '11 - 20',
              GamificationDict.titleSmart.get(true),
              GamificationDict.titleSmart.get(false),
            ]),
            _buildTableRow([
              '21 - 30',
              GamificationDict.titleWise.get(true),
              GamificationDict.titleWise.get(false),
            ]),
            _buildTableRow([
              '31 - 49',
              GamificationDict.titleWealth.get(true),
              GamificationDict.titleWealth.get(false),
            ]),
            _buildTableRow([
              '50+',
              GamificationDict.titleWealth.get(true),
              GamificationDict.titleWealth.get(false),
            ]),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(List<String> cells, {bool isHeader = false}) {
    return TableRow(
      decoration: BoxDecoration(
        color: isHeader
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
      ),
      children: cells.map((cell) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Text(
            cell,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              color: isHeader ? AppColors.primary : Colors.white,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMechanismCard(
    String title,
    String desc, {
    required FaIconData icon,
    Color color = AppColors.primary,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.03),
        border: Border.all(color: color.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(icon, size: 16, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(height: 4),
                MarkdownTextParser(
                  rawText: desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
