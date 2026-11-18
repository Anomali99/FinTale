// Layar tinjau draf transaksi dari server.
// Draf TIDAK disimpan otomatis — pengguna harus mengonfirmasi.
// Dipanggil setelah OCR, suara, atau notifikasi menghasilkan draf.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/transaction_draft.dart';

class DraftReviewScreen extends StatelessWidget {
  final TransactionDraft draft;

  /// Dipanggil saat pengguna menekan "Simpan" setelah meninjau draf.
  /// Pembuat screen bertanggung jawab menyimpan ke DB.
  final void Function(TransactionDraft draft) onConfirm;

  const DraftReviewScreen({
    super.key,
    required this.draft,
    required this.onConfirm,
  });

  static const routeName = '/draft-review';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tinjau Draf Transaksi'),
        backgroundColor: colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner peringatan draf
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ini adalah draf dari server. Periksa dan sesuaikan sebelum menyimpan.',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Informasi draf
            _InfoRow(
              label: 'Jenis',
              value: draft.type == 'expense' ? 'Pengeluaran' : 'Pemasukan',
              valueColor: draft.type == 'expense'
                  ? colorScheme.error
                  : Colors.green,
            ),
            _InfoRow(
              label: 'Nominal',
              value: currencyFormat.format(draft.amount),
            ),
            _InfoRow(
              label: 'Waktu',
              value: dateFormat.format(draft.occurredAt.toLocal()),
            ),
            if (draft.merchant != null)
              _InfoRow(label: 'Merchant / Judul', value: draft.merchant!),
            if (draft.note != null)
              _InfoRow(label: 'Catatan', value: draft.note!),
            if (draft.walletId != null)
              _InfoRow(label: 'ID Dompet', value: '${draft.walletId}'),
            if (draft.categoryId != null)
              _InfoRow(label: 'Kategori', value: draft.categoryId!),
            const SizedBox(height: 8),

            // Confidence bar
            Row(
              children: [
                const Text(
                  'Kepercayaan server: ',
                  style: TextStyle(fontSize: 13),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: draft.confidence.clamp(0.0, 1.0),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(draft.confidence * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Tombol aksi
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirm(draft);
                    },
                    child: const Text('Simpan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: valueColor ?? colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
