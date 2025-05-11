import 'package:flutter/material.dart';
import 'package:tax_invoice_new/features/resources/custom_color.dart';

class CustomBottomSheet {
  static Future<dynamic> buildCastingDoorBottomSheetDraggable(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
    double initialChildSize = 0.5,
    double maxChildSize = 0.9,
    Color backgroundColor = CustomColor.mainWhiteColor,
  }) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: initialChildSize,
          maxChildSize: maxChildSize,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                color: backgroundColor,
              ),
              child: ListView(
                controller: scrollController,
                shrinkWrap: true,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: CustomColor.boxDisableGreyColor,
                        ),
                        width: MediaQuery.of(context).size.width / 4,
                        height: 4,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                  SafeArea(child: child),
                ],
              ),
            );
          },
        );
      },
      backgroundColor: CustomColor.transparentColor,
      isScrollControlled: true,
      isDismissible: isDismissible,
    );
  }

  static Future buildCastingDoorBottomSheet(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
    bool stopDrag = false,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: !stopDrag,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              color: CustomColor.mainWhiteColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: CustomColor.boxDisableGreyColor,
                      ),
                      width: MediaQuery.of(context).size.width / 4,
                      height: 4,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
                child,
              ],
            ),
          ),
        );
      },
      backgroundColor: CustomColor.transparentColor,
      isDismissible: isDismissible,
    );
  }
}
