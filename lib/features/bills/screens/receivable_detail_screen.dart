import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../controllers/settings_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/number_utils.dart';
import '../../../models/receivable_model.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_table.dart';

class ReceivableDetailScreen extends StatefulWidget {
  final String borrowerName;
  final List<ReceivableModel> initialRecords;

  const ReceivableDetailScreen({
    super.key,
    required this.borrowerName,
    required this.initialRecords,
  });

  @override
  State<ReceivableDetailScreen> createState() => _ReceivableDetailScreenState();
}

class _ReceivableDetailScreenState extends State<ReceivableDetailScreen> {
  late List<ReceivableModel> _records;

  @override
  void initState() {
    super.initState();
    _records = List.from(widget.initialRecords);
  }

  String _formatDate(int timestamp) {
    if (timestamp == 0) return 'Tanpa Tanggal';
    return DateFormat(
      'dd MMM yyyy',
    ).format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();
    final colorScheme = Theme.of(context).colorScheme;

    final isRpg = settingsController.isRpgMode;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(title: Text(widget.borrowerName), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(24.0),
        itemCount: _records.length,
        itemBuilder: (context, index) {
          final item = _records[index];

          return Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
            margin: const EdgeInsets.only(bottom: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: item.isFinished
                    ? AppColors.getSuccess(context).withOpacity(0.3)
                    : colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: item.isFinished
                              ? AppColors.getSuccess(context).withOpacity(0.15)
                              : colorScheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.isFinished
                              ? (isRpg ? "TUNTAS" : "LUNAS")
                              : (isRpg ? "BERJALAN" : "BELUM LUNAS"),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: item.isFinished
                                ? AppColors.getSuccess(context)
                                : colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (item.isFinished) ...[
                    CustomTable(
                      color: colorScheme.surfaceContainerHighest,
                      borderColor: AppColors.getSuccess(context),
                      children: [
                        CustomRowTable(
                          label: isRpg
                              ? "Total Koin Dipinjamkan"
                              : "Total Pinjaman",
                          value: NumberUtils.toIdr(item.amount),
                          valueColor: colorScheme.onSurface,
                          boldValue: true,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Divider(
                            color: colorScheme.onSurface.withOpacity(0.05),
                            height: 1,
                          ),
                        ),
                        CustomRowTable(
                          label: isRpg ? "Tanggal Kontrak" : "Tanggal Pinjam",
                          value: _formatDate(item.dateTimestamp),
                        ),
                        const SizedBox(height: 6),
                        CustomRowTable(
                          label: isRpg ? "Tanggal Tuntas" : "Tanggal Lunas",

                          value: item.targetDate != null
                              ? _formatDate(item.targetDate!)
                              : 'Tanpa Tanggal',
                          valueColor: AppColors.getSuccess(context),
                          boldValue: true,
                        ),
                      ],
                    ),
                  ] else ...[
                    CustomTable(
                      color: colorScheme.surfaceContainerHighest,
                      borderColor: colorScheme.primary,
                      children: [
                        CustomRowTable(
                          label: isRpg ? "Sisa Target Emas" : "Sisa Piutang",
                          value: NumberUtils.toIdr(item.currentReceivable),
                          valueColor: colorScheme.primary,
                          boldValue: true,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Divider(
                            color: colorScheme.onSurface.withOpacity(0.05),
                            height: 1,
                          ),
                        ),
                        CustomRowTable(
                          label: isRpg
                              ? "Total Koin Dipinjamkan"
                              : "Total Pinjaman",
                          value: NumberUtils.toIdr(item.amount),
                        ),
                        const SizedBox(height: 6),
                        CustomRowTable(
                          label: isRpg ? "Emas Dikembalikan" : "Sudah Dibayar",
                          value: NumberUtils.toIdr(item.paidAmount),
                          valueColor: AppColors.getSuccess(context),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: item.returnPercentage,
                            backgroundColor: Theme.of(
                              context,
                            ).scaffoldBackgroundColor,
                            color: AppColors.getSuccess(context),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.onSurface.withOpacity(0.05),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isRpg ? "Tanggal Kontrak" : "Tanggal Pinjam",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(item.dateTimestamp),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                isRpg ? "Batas Penagihan" : "Tanggal Tenggat",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.targetDate != null
                                    ? _formatDate(item.targetDate!)
                                    : 'Tanpa Tenggat',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.solidBell,
                              size: 16,
                              color: item.isReminderActive
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isRpg
                                  ? "Notifikasi Tagihan"
                                  : "Notifikasi Penagihan",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: item.isReminderActive,
                          activeThumbColor: colorScheme.primary,
                          onChanged: (val) {
                            setState(() {
                              item.setReminderActive(val);
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      title: isRpg ? "Sita Loot / Cicil" : "Catat Pembayaran",
                      color: AppColors.getSuccess(context),
                      onTap: () {},
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
