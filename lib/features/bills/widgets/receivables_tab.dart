import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/utils/number_utils.dart';
import '../../../models/receivable_model.dart';

class ReceivablesTab extends StatelessWidget {
  final bool isRpg;
  final Map<String, List<ReceivableModel>> data;
  final Function(String, List<ReceivableModel>) onTapCard;

  const ReceivablesTab({
    super.key,
    required this.data,
    required this.isRpg,
    required this.onTapCard,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.beerMugEmpty,
              size: 48,
              color: colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 16),
            Text(
              isRpg
                  ? "Tidak ada Kontrak Tavern aktif."
                  : "Tidak ada piutang aktif.",
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24.0),
      itemCount: data.length,
      itemBuilder: (context, index) {
        String borrower = data.keys.elementAt(index);
        List<ReceivableModel> records = data[borrower] ?? [];

        Decimal totalRemaining = Decimal.zero;
        for (var item in records) {
          totalRemaining += item.currentReceivable;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => onTapCard(borrower, records),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.primary.withOpacity(0.15),
                    child: FaIcon(
                      FontAwesomeIcons.user,
                      color: colorScheme.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          borrower,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${records.length} ${isRpg ? 'Kontrak Aktif' : 'Catatan Piutang'}",
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        isRpg ? "Sisa Emas" : "Sisa Piutang",
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        NumberUtils.toIdr(totalRemaining),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
