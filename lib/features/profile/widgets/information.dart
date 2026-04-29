import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skill_dict.dart';
import '../../../core/constants/title_dict.dart';
import '../../../models/allocation_model.dart';
import '../../../widgets/markdown_text_parser.dart';

class Information extends StatelessWidget {
  const Information({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Guide & Information',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildSectionHeader('Missions'),
          const SizedBox(height: 16),
          _buildMissionCard(
            icon: FontAwesomeIcons.penToSquare,
            title: '[Record Transaction]',
            desc: 'Log your daily income and expenses.',
            xp: '+10 XP',
            frequency: 'Daily',
            limit: '3x / Day',
            color: Colors.blueAccent,
          ),
          _buildMissionCard(
            icon: FontAwesomeIcons.wallet,
            title: '[Daily Budget Cap]',
            desc: 'End the day without exceeding your daily budget limit.',
            xp: '+25 XP',
            frequency: 'Daily',
            limit: '1x / Day',
            color: Colors.greenAccent,
          ),
          _buildMissionCard(
            icon: FontAwesomeIcons.calendarCheck,
            title: '[Weekly Check-in]',
            desc: 'Open the app for at least 5 days within a week.',
            xp: '+100 XP',
            frequency: 'Weekly',
            limit: '1x / Week',
            color: Colors.teal,
          ),
          _buildMissionCard(
            icon: FontAwesomeIcons.chartLine,
            title: '[Consistent Budgeting]',
            desc: 'Maintain your daily budget cap for 5 days in a week.',
            xp: '+150 XP',
            frequency: 'Weekly',
            limit: '1x / Week',
            color: Colors.cyan,
          ),
          _buildMissionCard(
            icon: FontAwesomeIcons.piggyBank,
            title: '[Monthly Savings Goal]',
            desc: 'Successfully reach your targeted savings for the month.',
            xp: '+500 XP',
            frequency: 'Monthly',
            limit: '1x / Month',
            color: Colors.amber,
          ),
          _buildMissionCard(
            icon: FontAwesomeIcons.fileInvoiceDollar,
            title: '[Debt Payment]',
            desc: 'Pay off your monthly [Debt] allocation on time.',
            xp: '+300 XP',
            frequency: 'Monthly',
            limit: '1x / Month',
            color: Colors.redAccent,
          ),
          _buildMissionCard(
            icon: FontAwesomeIcons.chartPie,
            title: '[Monthly Review]',
            desc: 'Review your financial summary at the end of the month.',
            xp: '+200 XP',
            frequency: 'Monthly',
            limit: '1x / Month',
            color: Colors.deepOrangeAccent,
          ),
          _buildMissionCard(
            icon: FontAwesomeIcons.flagCheckered,
            title: '[First Transaction]',
            desc: 'Record your very first financial transaction.',
            xp: '+100 XP',
            frequency: 'Unique',
            limit: 'Once',
            color: Colors.pinkAccent,
          ),
          _buildMissionCard(
            icon: FontAwesomeIcons.buildingColumns,
            title: '[Create Wallet]',
            desc: 'Create a new storage, bank account, or e-wallet.',
            xp: '+50 XP',
            frequency: 'Unique',
            limit: 'Max 3 Wallets',
            color: Colors.purpleAccent,
          ),
          _buildMissionCard(
            icon: FontAwesomeIcons.sliders,
            title: '[Set Allocation]',
            desc:
                'Set up your financial allocation percentages for the first time.',
            xp: '+200 XP',
            frequency: 'Unique',
            limit: 'Once',
            color: Colors.indigoAccent,
          ),

          const SizedBox(height: 32),

          _buildSectionHeader('Title System'),
          const SizedBox(height: 16),
          _buildTitleTable(),

          const SizedBox(height: 32),

          _buildSectionHeader('Allocation Guide'),
          const SizedBox(height: 16),

          _buildLevelTierCard(
            level: '1 - 10',
            title: TitleDict.noviceSaver.get(false),
            skills: {
              SectorType.living: {
                "value": "55% ± 5%",
                "sub": {
                  SubSectorType.essentials: "55% ± 5%",
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
            title: TitleDict.smartBudgeter.get(false),
            skills: {
              SectorType.living: {
                "value": "50% ± 5%",
                "sub": {
                  SubSectorType.essentials: "50% ± 5%",
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
            title: TitleDict.wiseInvestor.get(false),
            skills: {
              SectorType.living: {
                "value": "45% ± 7%",
                "sub": {
                  SubSectorType.essentials: "45% ± 7%",
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
            title: TitleDict.wealthBuilder.get(false),
            skills: {
              SectorType.living: {
                "value": "40% ± 7%",
                "sub": {
                  SubSectorType.essentials: "40% ± 7%",
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
            title: TitleDict.wealthBuilder.get(false),
            skills: {
              SectorType.living: {
                "value": "35% ± 10%",
                "sub": {
                  SubSectorType.essentials: "35% ± 10%",
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
            title: TitleDict.financialMaster.get(false),
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

          _buildSectionHeader('Rules of Conduct'),
          const SizedBox(height: 12),
          _buildMechanismCard(
            'The ${SkillDict.lowRisk.get(false)} Hybrid Priority',
            'The `${SkillDict.lowRisk.get(false)}` node draws its percentage from both `${SkillDict.emergency.get(false)}` and `${SkillDict.investment.get(false)}`. **`${SkillDict.emergency.get(false)}` is the absolute priority.** For example, a 30% `${SkillDict.lowRisk.get(false)}` allocation will fully drain the 20% `${SkillDict.emergency.get(false)}` capacity first before taking the remaining 10% from `${SkillDict.investment.get(false)}`.',
            icon: FontAwesomeIcons.arrowsDownToLine,
          ),
          _buildMechanismCard(
            '${SkillDict.dailyRoutine.get(false)} & ${SkillDict.dreamFund.get(false)} Synergy',
            'The `${SkillDict.dailyRoutine.get(false)}` child node shares its pool with `${SkillDict.dreamFund.get(false)}`. You have the strategic freedom to save your daily budget into `${SkillDict.dreamFund.get(false)}` to purchase future legendary gear.',
            icon: FontAwesomeIcons.handHoldingHeart,
          ),
          _buildMechanismCard(
            'Free Allocation State',
            'Once your `${SkillDict.debt.get(false)}` is purged or `${SkillDict.emergency.get(false)}` is at max capacity, you unlock "Free Mode" where points can be redistributed to any node in the tree.',
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
                  SkillDict.dailyParent.icon(false),
                  SkillDict.dailyParent.get(false),
                  skills[SectorType.living]['value'],
                  SkillDict.dailyParent.color ?? Colors.blueAccent,
                ),
                _buildSubStatRow(
                  '- ${SkillDict.dailyRoutine.get(false)}',
                  skills[SectorType.living]['sub'][SubSectorType.essentials],
                ),
                _buildSubStatRow(
                  '- ${SkillDict.dreamFund.get(false)}',
                  skills[SectorType.living]['sub'][SubSectorType.dreamFund],
                ),
                const SizedBox(height: 12),

                _buildStatRow(
                  SkillDict.debt.icon(false),
                  SkillDict.debt.get(false),
                  skills[SectorType.payDebt]['value'],
                  SkillDict.debt.color ?? Colors.redAccent,
                ),
                const SizedBox(height: 12),

                _buildStatRow(
                  SkillDict.emergency.icon(false),
                  SkillDict.emergency.get(false),
                  skills[SectorType.emergency]['value'],
                  SkillDict.emergency.color ?? Colors.greenAccent,
                ),
                _buildSubStatRow(
                  '- ${SkillDict.lowRisk.get(false)}',
                  skills[SectorType.emergency]['sub'][SubSectorType.lowRisk],
                ),
                const SizedBox(height: 12),

                _buildStatRow(
                  SkillDict.investment.icon(false),
                  SkillDict.investment.get(false),
                  skills[SectorType.investment]['value'],
                  SkillDict.investment.color ?? Colors.purpleAccent,
                ),

                _buildSubStatRow(
                  '- ${SkillDict.lowRisk.get(false)}',
                  skills[SectorType.investment]['sub'][SubSectorType.lowRisk],
                ),
                _buildSubStatRow(
                  '- ${SkillDict.mediumRisk.get(false)}',
                  skills[SectorType.investment]['sub'][SubSectorType
                      .mediumRisk],
                ),
                _buildSubStatRow(
                  '- ${SkillDict.highRisk.get(false)}',
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

  Widget _buildMissionCard({
    required FaIconData icon,
    required String title,
    required String desc,
    required String xp,
    required String frequency,
    required String limit,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: FaIcon(icon, size: 80, color: color.withOpacity(0.05)),
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
                          FaIcon(icon, size: 18, color: color),
                          const SizedBox(width: 10),
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          frequency,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    desc,
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
                        'Limit: $limit',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        xp,
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
            _buildTableRow(['Level', 'RPG Title', 'Standard'], isHeader: true),
            _buildTableRow([
              '1 - 10',
              TitleDict.noviceSaver.get(true),
              TitleDict.noviceSaver.get(false),
            ]),
            _buildTableRow([
              '11 - 20',
              TitleDict.smartBudgeter.get(true),
              TitleDict.smartBudgeter.get(false),
            ]),
            _buildTableRow([
              '21 - 30',
              TitleDict.wiseInvestor.get(true),
              TitleDict.wiseInvestor.get(false),
            ]),
            _buildTableRow([
              '31 - 49',
              TitleDict.wealthBuilder.get(true),
              TitleDict.wealthBuilder.get(false),
            ]),
            _buildTableRow([
              '50+',
              TitleDict.financialMaster.get(true),
              TitleDict.financialMaster.get(false),
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
