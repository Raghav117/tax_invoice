import 'package:flutter/material.dart';
import 'package:tax_invoice_new/features/resources/custom_color.dart';
import 'package:tax_invoice_new/features/resources/custom_text_style.dart';

class CastingDoorButton extends StatelessWidget {
  CastingDoorButton({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.isLargeButton = false,
    this.isLoading = false,
    required this.onEnableCta,
    this.onDisableCta,
    required this.isDisabled,
    this.borderRadius = 15,
    this.borderColor = CustomColor.transparentColor,
    this.disabledColor,
    this.buttonColor,
    this.padding = const EdgeInsets.all(8.0),
  });

  final double? width;
  final double? height;

  final Widget child;
  final bool isLargeButton;
  bool isLoading;

  final VoidCallback onEnableCta;
  final VoidCallback? onDisableCta;
  final Color? buttonColor;
  final EdgeInsets padding;

  final bool isDisabled;

  final double borderRadius;

  final Color borderColor;
  final Color? disabledColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          isDisabled
              ? onDisableCta
              : () {
                if (!isLoading) {
                  onEnableCta();
                }
              },
      child:
          isLargeButton
              ? Row(children: [Expanded(child: buildButtonWidget())])
              : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [buildButtonWidget()],
              ),
    );
  }

  Widget buildButtonWidget() {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(borderRadius),
        color:
            isDisabled
                ? disabledColor ?? CustomColor.boxDisableGreyColor
                : (buttonColor ?? CustomColor.primaryBlueColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (isLoading)
            Center(
              child: Transform(
                transform: Transform.scale(scale: 0.8).transform,
                child: const CircularProgressIndicator(
                  color: CustomColor.mainWhiteColor,
                ),
              ),
            ),
          (child),
        ],
      ),
    );
  }
}

class CastingDoorTextButton extends StatelessWidget {
  const CastingDoorTextButton({
    super.key,
    this.textColor,
    required this.title,
    this.onTap,
    this.onDisableTap,
    this.isDisable = false,
    this.style = CustomTextStyle.heading12Bold,
  });

  final Color? textColor;
  final String title;
  final TextStyle style;
  final VoidCallback? onTap;
  final VoidCallback? onDisableTap;
  final bool isDisable;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDisable ? onDisableTap : onTap,
      child: Text(
        title,
        style: style.copyWith(
          color:
              isDisable
                  ? CustomColor.boxDisableGreyColor
                  : textColor ?? CustomColor.primaryBlueColor,
        ),
      ),
    );
  }
}
