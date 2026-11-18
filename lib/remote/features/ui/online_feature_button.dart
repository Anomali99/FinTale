// Widget tombol fitur online yang menampilkan alasan nonaktif jika status bukan available.
// Tampil nonaktif (disabled) dengan tooltip/pesan jika status bukan FeatureStatus.available.

import 'package:flutter/material.dart';

import '../../enums/online_feature.dart';

class OnlineFeatureButton extends StatelessWidget {
  final OnlineFeature feature;
  final FeatureStatus status;
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const OnlineFeatureButton({
    super.key,
    required this.feature,
    required this.status,
    required this.label,
    required this.icon,
    this.onPressed,
  });

  bool get _isAvailable => status == FeatureStatus.available;

  /// Pesan alasan nonaktif yang ditampilkan ke pengguna.
  String get _disabledReason {
    switch (status) {
      case FeatureStatus.noServer:
        return 'Server tidak dikonfigurasi. Fitur online tidak tersedia.';
      case FeatureStatus.offline:
        return 'Tidak ada koneksi internet atau server tidak terjangkau.';
      case FeatureStatus.notSubscribed:
        return 'Fitur ini memerlukan langganan FinTale Online.';
      case FeatureStatus.available:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final button = FilledButton.icon(
      onPressed: _isAvailable ? onPressed : null,
      icon: Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(
        disabledBackgroundColor: colorScheme.surfaceContainerHighest,
        disabledForegroundColor: colorScheme.onSurfaceVariant,
      ),
    );

    if (_isAvailable) return button;

    // Tampilkan alasan nonaktif di bawah tombol
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        button,
        const SizedBox(height: 6),
        Text(
          _disabledReason,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
