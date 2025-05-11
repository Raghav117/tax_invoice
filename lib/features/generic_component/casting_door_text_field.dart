// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tax_invoice_new/features/generic_component/casting_door_divider.dart';
import 'package:tax_invoice_new/features/resources/custom_color.dart';
import 'package:tax_invoice_new/features/resources/custom_text_style.dart';

enum CastingDoorTextFieldState { normal, validate, error }

class CastingDoorLeadingIconActiveInActive {
  final Widget leadingInActiveTextFieldIcon;
  final Widget leadingActiveTextFieldIcon;
  CastingDoorLeadingIconActiveInActive({
    required this.leadingActiveTextFieldIcon,
    required this.leadingInActiveTextFieldIcon,
  });
}

class CastingDoorTextFiled extends StatefulWidget {
  CastingDoorTextFiled({
    super.key,
    this.labelText,
    this.hintText,
    required this.castingDoorTextFieldState,
    this.containerInActiveBorderColor,
    this.leadingPermanentIcon,
    this.leadingActiveIcon,
    this.errorMessage,
    this.validateFunc,
    this.onTextChange,
    this.textCapitalization = TextCapitalization.words,
    this.textInputType,
    this.obscureText = false,
    this.containerColor,
    this.castingDoorLeadingIconActiveInActive,
    this.maxLength,
    this.borderRadius = 10,
    this.trailingIcon,
    this.maxLines = 1,
    this.minLines = 1,
    this.containerBorderColorTextFieldActive,
    this.controller,
    this.focusNode,
    this.textAlign = TextAlign.start,
    this.isOnlyAlphabetSpace = false,
    this.inputFormatters = const [],
    this.isDigists = false,
    this.isDisable = false,
    this.isPassword = false,
    this.maxValue,
    TextStyle? textStyle,
    this.onFocusChange,
    this.height,
  }) {
    textStyle ??= CustomTextStyle.heading14.copyWith(
      color: CustomColor.contrastBlackColor,
    );
    style = textStyle;
  }

  final double? height;
  final double? maxValue;

  final String? labelText;
  final String? hintText;
  TextEditingController? controller;
  final Widget? leadingPermanentIcon;
  final Widget? leadingActiveIcon;
  final TextCapitalization textCapitalization;
  final TextInputType? textInputType;
  bool obscureText;
  final CastingDoorTextFieldState castingDoorTextFieldState;
  final String? errorMessage;
  final int? maxLength;
  final int maxLines;
  final int minLines;
  final VoidCallback? validateFunc;
  final ValueSetter<String>? onTextChange;
  final Color? containerColor;
  final Color? containerBorderColorTextFieldActive;
  final Color? containerInActiveBorderColor;
  final CastingDoorLeadingIconActiveInActive?
  castingDoorLeadingIconActiveInActive;
  final double borderRadius;
  final Widget? trailingIcon;
  final bool isDisable;
  final bool isDigists;
  final List<TextInputFormatter> inputFormatters;
  final TextAlign textAlign;
  final FocusNode? focusNode;
  final ValueSetter<bool>? onFocusChange;
  final bool isPassword;
  late TextStyle style;
  final bool isOnlyAlphabetSpace;

  @override
  State<CastingDoorTextFiled> createState() => _CastingDoorTextFiledState();
}

class _CastingDoorTextFiledState extends State<CastingDoorTextFiled> {
  bool isTextFiledActive = false;

  bool isErrorMessageShown = false;

  void trimSpaceAtStart(String value) async {
    int i = 0;
    while (i < value.length && value[i] == ' ') {
      if (widget.controller != null) {
        widget.controller!.text = widget.controller!.text.trim();
      }
    }
  }

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    widget.controller ??= TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (value) {
        if (widget.onFocusChange != null) {
          widget.onFocusChange!(value);
        }
        if (value == false) {
          isErrorMessageShown = true;
          isTextFiledActive = false;
          setState(() {});
          if (widget.validateFunc != null) {
            widget.validateFunc!();
          }
        } else {
          isErrorMessageShown = false;
          isTextFiledActive = true;
          setState(() {});
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.errorMessage != null &&
              widget.castingDoorTextFieldState ==
                  CastingDoorTextFieldState.error &&
              isErrorMessageShown &&
              !isTextFiledActive) ...[
            Text(widget.errorMessage!, style: CustomTextStyle.errorHeading10),
            const SizedBox(height: 4),
          ],
          Container(
            constraints:
                widget.height == null
                    ? null
                    : BoxConstraints(minHeight: widget.height!),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              color: widget.containerColor ?? CustomColor.mainWhiteColor,
              border: Border.all(
                color:
                    isTextFiledActive
                        ? widget.containerBorderColorTextFieldActive ??
                            CustomColor.primaryBlueColor.withOpacity(0.5)
                        : widget.containerInActiveBorderColor ??
                            CustomColor.glassBlackShadeAppBarColor,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                if (widget.leadingPermanentIcon != null) ...[
                  widget.leadingPermanentIcon!,
                  const SizedBox(width: 8),
                  CastingDoorDivider(
                    height: widget.height == null ? 30 : (widget.height! - 20),
                    color: CustomColor.glassBlackShadeAppBarColor,
                    width: 1,
                  ),
                  const SizedBox(width: 8),
                ],
                if (widget.castingDoorLeadingIconActiveInActive != null) ...[
                  if (isTextFiledActive)
                    widget
                        .castingDoorLeadingIconActiveInActive!
                        .leadingActiveTextFieldIcon,
                  if (!isTextFiledActive)
                    widget
                        .castingDoorLeadingIconActiveInActive!
                        .leadingInActiveTextFieldIcon,
                  const SizedBox(width: 8),
                  CastingDoorDivider(
                    height: widget.height == null ? 30 : (widget.height! - 10),
                    color: CustomColor.glassBlackShadeAppBarColor,
                    width: 1,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Scrollbar(
                        controller: scrollController,
                        trackVisibility: true,
                        thumbVisibility: true,
                        child: TextFormField(
                          enabled: !widget.isDisable,
                          scrollController: scrollController,
                          focusNode: widget.focusNode,
                          maxLength: widget.maxLength,
                          maxLines: widget.maxLines,
                          minLines: widget.minLines,
                          inputFormatters: [
                            if (widget.isOnlyAlphabetSpace) ...[
                              FilteringTextInputFormatter.allow(
                                RegExp('[a-zA-Z ]'),
                              ),
                              FilteringTextInputFormatter.deny(RegExp(r'^\s+')),
                            ],
                            if (widget.textInputType == TextInputType.number)
                              FilteringTextInputFormatter.digitsOnly,
                            ...widget.inputFormatters,
                          ],
                          onChanged: (value) async {
                            if (widget.onTextChange != null) {
                              widget.onTextChange!(value);
                            }
                            if (widget.maxValue != null) {
                              double parsedValue =
                                  double.tryParse(value) ?? 0.0;
                              await Future.delayed(
                                const Duration(milliseconds: 100),
                              );
                              if (parsedValue > widget.maxValue!) {
                                // value = value.substring(0, value.length - 1);
                                widget.controller!.text = widget
                                    .controller!
                                    .text
                                    .substring(0, value.length - 1);
                                widget
                                    .controller!
                                    .selection = TextSelection.fromPosition(
                                  TextPosition(offset: value.length - 1),
                                );
                              }
                            }
                          },
                          textAlign: widget.textAlign,
                          controller: widget.controller,
                          obscureText: widget.obscureText,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            suffixIcon:
                                widget.isPassword
                                    ? InkWell(
                                      onTap: () {
                                        widget.obscureText =
                                            !widget.obscureText;
                                        setState(() {});
                                      },
                                      child: const Icon(
                                        Icons.remove_red_eye_outlined,
                                        color: CustomColor.primaryBlueColor,
                                      ),
                                    )
                                    : null,
                            counterText: '',
                            hintText: widget.hintText,
                            label:
                                widget.labelText == null
                                    ? null
                                    : Text(
                                      widget.labelText!,
                                      style: CustomTextStyle.heading12.copyWith(
                                        color:
                                            isTextFiledActive
                                                ? CustomColor.primaryBlueColor
                                                : widget.castingDoorTextFieldState ==
                                                    CastingDoorTextFieldState
                                                        .normal
                                                ? CustomColor.contrastBlackColor
                                                : widget.castingDoorTextFieldState ==
                                                    CastingDoorTextFieldState
                                                        .error
                                                ? CustomColor.errorColor
                                                : CustomColor.sucessColor,
                                      ),
                                    ),
                          ),
                          textCapitalization: widget.textCapitalization,
                          keyboardType:
                              widget.isDigists
                                  ? const TextInputType.numberWithOptions(
                                    decimal: true,
                                  )
                                  : widget.textInputType,
                          style: widget.style,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.trailingIcon != null) widget.trailingIcon!,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
