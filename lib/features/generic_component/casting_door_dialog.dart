import 'package:flutter/material.dart';

import '../resources/custom_color.dart';

class CastingDoorDialog {
  CastingDoorDialog._();

  static Future<void> castingDoorDialog(
    BuildContext context, {
    Widget? content,
    List<Widget>? actions,
    double padding = 16,
  }) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Material(
            color: CustomColor.transparentColor,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.all(padding),
              backgroundColor: CustomColor.mainWhiteColor,
              elevation: 0,
              content: InkWell(onTap: () {}, child: content),
              actions: actions,
            ),
          ),
        );
      },
    );
  }

  static Future castingDoorFullScreenDialog(
    BuildContext context, {
    Widget? content,
    Future<bool> Function()? onWillPop,
    required List<Widget> actions,
  }) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: onWillPop,
          child: Material(
            color: CustomColor.transparentColor,
            child: InkWell(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: SizedBox(
                // height: double.infinity,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: CustomColor.mainWhiteColor,
                  elevation: 0,
                  content: content,
                  actions: actions,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
