import 'package:flutter/material.dart';
import 'package:tax_invoice_new/features/resources/custom_color.dart';

class CastingDoorDivider extends StatelessWidget {
  CastingDoorDivider({
    super.key,
    required this.height,
    required this.width,
    this.color,
  });

  final double height;
  final double width;
  Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: color ?? CustomColor.dividerColorBlackShade,
    );
  }
}
