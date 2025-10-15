// core/theme/fast_spacing.dart
import 'package:flutter/material.dart';

class FastSpacing {
  // Valeurs de base
  static const double space0 = 0;
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;
  static const double space56 = 56;
  static const double space64 = 64;

  // Padding
  static const EdgeInsets p0 = EdgeInsets.all(space0);
  static const EdgeInsets p4 = EdgeInsets.all(space4);
  static const EdgeInsets p8 = EdgeInsets.all(space8);
  static const EdgeInsets p16 = EdgeInsets.all(space16);
  static const EdgeInsets p24 = EdgeInsets.all(space24);
  static const EdgeInsets p32 = EdgeInsets.all(space32);

  // Padding Horizontal
  static const EdgeInsets px0 = EdgeInsets.symmetric();
  static const EdgeInsets px4 = EdgeInsets.symmetric(horizontal: space4);
  static const EdgeInsets px8 = EdgeInsets.symmetric(horizontal: space8);
  static const EdgeInsets px16 = EdgeInsets.symmetric(horizontal: space16);
  static const EdgeInsets px24 = EdgeInsets.symmetric(horizontal: space24);
  static const EdgeInsets px32 = EdgeInsets.symmetric(horizontal: space32);

  // Padding Vertical
  static const EdgeInsets py0 = EdgeInsets.symmetric();
  static const EdgeInsets py4 = EdgeInsets.symmetric(vertical: space4);
  static const EdgeInsets py8 = EdgeInsets.symmetric(vertical: space8);
  static const EdgeInsets py16 = EdgeInsets.symmetric(vertical: space16);
  static const EdgeInsets py24 = EdgeInsets.symmetric(vertical: space24);
  static const EdgeInsets py32 = EdgeInsets.symmetric(vertical: space32);

  // Gaps Verticaux (height)
  static const SizedBox h0 = SizedBox(height: space0);
  static const SizedBox h4 = SizedBox(height: space4);
  static const SizedBox h8 = SizedBox(height: space8);
  static const SizedBox h16 = SizedBox(height: space16);
  static const SizedBox h24 = SizedBox(height: space24);
  static const SizedBox h32 = SizedBox(height: space32);

  // Gaps Horizontaux (width)
  static const SizedBox w0 = SizedBox(width: space0);
  static const SizedBox w4 = SizedBox(width: space4);
  static const SizedBox w8 = SizedBox(width: space8);
  static const SizedBox w16 = SizedBox(width: space16);
  static const SizedBox w24 = SizedBox(width: space24);
  static const SizedBox w32 = SizedBox(width: space32);
}
