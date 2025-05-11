// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:tax_invoice_new/features/generic_component/overlays/custom_overlay_indicator.dart';

class CastingDoorSnackBar {
  CastingDoorSnackBar._();
  static void snackBar({
    required BuildContext context,
    required String message,
    required bool isSucess,
    Duration? duration,
  }) async {
    if (context.mounted) {
      CustomOverlayIndicator overlayIndicator = CustomOverlayIndicator();
      overlayIndicator.insertOverlay(
        context,
        message: message,
        customOverlayIndicatorType:
            isSucess
                ? CustomOverlayIndicatorType.success
                : CustomOverlayIndicatorType.error,
      );
      await Future.delayed(duration ?? const Duration(seconds: 3));
      overlayIndicator.removeOverlay();
    }
  }
}
