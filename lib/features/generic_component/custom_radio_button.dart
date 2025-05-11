import 'package:flutter/material.dart';
import 'package:tax_invoice_new/features/resources/custom_text_style.dart';

class CustomRadioButton extends StatelessWidget {
  const CustomRadioButton({
    super.key,
    required this.isActive,
    required this.radioButtonColor,
    required this.title,
    this.style,
  });

  final bool isActive;
  final String title;
  final Color radioButtonColor;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: style ?? CustomTextStyle.heading12Bold),
        const Spacer(),
        isActive
            ? Icon(
              Icons.radio_button_checked_outlined,
              color: radioButtonColor,
              size: 24,
            )
            : Icon(Icons.circle_outlined, color: radioButtonColor, size: 24),
      ],
    );
  }
}
