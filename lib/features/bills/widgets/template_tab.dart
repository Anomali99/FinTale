import 'package:fintale/features/bills/widgets/template_card.dart';
import 'package:flutter/material.dart';

class TemplateTab extends StatelessWidget {
  final bool isRpg;

  const TemplateTab({super.key, required this.isRpg});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        TemplateCard(),
        TemplateCard(),
        TemplateCard(),
        TemplateCard(),
        TemplateCard(),
        TemplateCard(),
        const SizedBox(height: 100),
      ],
    );
  }
}
