import 'package:flutter/material.dart';
import 'package:tax_invoice_new/features/resources/custom_color.dart';
import 'package:tax_invoice_new/features/resources/custom_text_style.dart';

class CastingDoorSingleDatePicker extends StatelessWidget {
  CastingDoorSingleDatePicker({
    Key? key,
    required this.title,
    required this.onTap,
    required this.hintText,
    required this.date,
    this.initialDate,
  }) : super(key: key);

  final String title;
  final ValueSetter<DateTime?> onTap;
  final String hintText;
  final String date;

  DateTime? initialDate;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final dateTime = await showDatePicker(
          context: context,
          useRootNavigator: true,
          initialDate: initialDate ?? DateTime(DateTime.now().year - 3),
          firstDate: DateTime(1960),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: ThemeData(
                primaryColor: CustomColor.glassBlackShadeAppBarColor,
                splashColor: CustomColor.primaryBlueColor,
              ),
              child: child!,
            );
          },
        );
        onTap(dateTime);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: CustomColor.mainWhiteColor,
          border: Border.all(color: CustomColor.glassBlackShadeAppBarColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: CustomTextStyle.heading10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (date.isEmpty)
                    Text(
                      hintText,
                      style: CustomTextStyle.heading12.copyWith(
                        color: CustomColor.boxDisableGreyColor,
                      ),
                    ),
                  if (date.isNotEmpty)
                    Text(date, style: CustomTextStyle.heading12),
                  const Spacer(),
                  const Icon(
                    Icons.date_range,
                    color: CustomColor.primaryBlueColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
