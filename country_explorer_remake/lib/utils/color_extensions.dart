import 'package:flutter/material.dart';

extension ColorExtension on Color {
  Color withAlphaFactor(double factor) {
    return withAlpha((alpha * factor).round().clamp(0, 255));
  }
}
