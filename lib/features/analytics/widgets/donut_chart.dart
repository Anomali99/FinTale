import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/shared_dict.dart';
import '../../../core/utils/currency_formatter.dart';
import 'detail_card.dart';

class DonutChart extends StatelessWidget {
  final List<AnalyticCategory> activeData;
  final BigInt activeTotal;
  final bool showExpense;
  final bool isRpg;
  final int touchedIndex;
  final Color activeColor;
  final ValueChanged<int> onTouch;

  const DonutChart({
    super.key,
    required this.activeData,
    required this.activeTotal,
    required this.showExpense,
    required this.isRpg,
    required this.touchedIndex,
    required this.activeColor,
    required this.onTouch,
  });

  List<PieChartSectionData> _buildPieChartSections() {
    return List.generate(activeData.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 16.0 : 0.0;
      final radius = isTouched ? 60.0 : 50.0;
      final data = activeData[i];
      final percentage = (data.amount / activeTotal * 100).toStringAsFixed(0);

      return PieChartSectionData(
        color: data.color,
        value: data.amount.toDouble(),
        title: '$percentage%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black45, blurRadius: 2)],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PieChart(
          PieChartData(
            pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  onTouch(-1);
                  return;
                }
                onTouch(pieTouchResponse.touchedSection!.touchedSectionIndex);
              },
            ),
            borderData: FlBorderData(show: false),
            sectionsSpace: 2,
            centerSpaceRadius: 60,
            sections: _buildPieChartSections(),
          ),
          swapAnimationDuration: const Duration(milliseconds: 500),
          swapAnimationCurve: Curves.easeInOut,
        ),

        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                showExpense
                    ? 'Total ${SharedDict.expense.get(isRpg)}'
                    : 'Total ${SharedDict.invest.get(isRpg)}',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                CurrencyFormatter.convertToIdr(activeTotal),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: activeColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
