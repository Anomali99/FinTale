import 'package:flutter/material.dart';

extension AdaptiveColor on Color {
  Color adapt(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    if (!isLight) return this;

    final hsl = HSLColor.fromColor(this);

    if (hsl.lightness > 0.4) {
      return hsl
          .withLightness(0.35)
          .withSaturation((hsl.saturation + 0.15).clamp(0.0, 1.0))
          .toColor();
    }

    return this;
  }
}
