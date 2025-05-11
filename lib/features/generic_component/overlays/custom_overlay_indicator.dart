import 'package:flutter/material.dart';
import 'package:tax_invoice_new/features/resources/custom_color.dart';
import 'package:tax_invoice_new/features/resources/custom_text_style.dart';

enum CustomOverlayIndicatorType { loading, success, error }

class CustomOverlayIndicator {
  OverlayEntry? overlayEntry;
  void insertOverlay(
    BuildContext buildContext, {
    required String message,
    required CustomOverlayIndicatorType customOverlayIndicatorType,
  }) {
    overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          bottom: 80,
          right: 20,
          left: 20,
          child: Material(
            borderRadius: BorderRadius.circular(12),
            color:
                customOverlayIndicatorType == CustomOverlayIndicatorType.loading
                    ? CustomColor.transparentColor.withOpacity(0.1)
                    : customOverlayIndicatorType ==
                        CustomOverlayIndicatorType.error
                    ? CustomColor.errorColor
                    : CustomColor.sucessColor,
            child: Container(
              decoration: BoxDecoration(
                color: CustomColor.transparentColor.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      customOverlayIndicatorType ==
                              CustomOverlayIndicatorType.loading
                          ? CustomColor.boxDisableGreyColor
                          : customOverlayIndicatorType ==
                              CustomOverlayIndicatorType.error
                          ? CustomColor.errorColor
                          : CustomColor.sucessColor,
                ),
              ),
              // height: 50,
              padding: const EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      message,
                      style: CustomTextStyle.heading14Bold.copyWith(
                        color: CustomColor.mainWhiteColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    final overlay = Overlay.of(buildContext);
    if (overlayEntry != null) {
      overlay.insert(overlayEntry!);
    }
  }

  void removeOverlay() {
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null;
    }
  }
}
