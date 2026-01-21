import 'package:flutter/widgets.dart';

class D {
  static late double _width;
  static late double _height;

  static const double _designWidth = 390;
  static const double _designHeight = 844;

  static void init(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _width = size.width;
    _height = size.height;
  }

  static double w(double px) => px * (_width / _designWidth);
  static double h(double px) => px * (_height / _designHeight);
  static double f(double px) => px * (_width / _designWidth);
  static double r(double px) => px * (_width / _designWidth);

  static double get textXS => f(11);
  static double get textSM => f(12);
  static double get textBase => f(17);
  static double get textMD => f(18);
  static double get textLG => f(20);
  static double get textXL => f(24);
  static double get textXXL => f(32);

  static double get radiusSM => r(4);
  static double get radiusMD => r(8);
  static double get radiusLG => r(12);
  static double get radiusXL => r(20);
  static double get radiusXXL => r(90);

  static double get primaryButton => h(45);
  static double get secondaryButton => h(42);

  static double get iconXS => w(15);
  static double get iconSM => w(20);
  static double get iconMD => w(24);
  static double get iconLG => w(28);

  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
}

extension ResponsiveSize on num {
  double get w => D.w(toDouble());
  double get h => D.h(toDouble());
  double get f => D.f(toDouble());
  double get r => D.r(toDouble());

  Widget get gapW => SizedBox(width: w);
  Widget get gapH => SizedBox(height: h);
}
