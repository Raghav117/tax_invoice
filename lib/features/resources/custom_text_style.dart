import 'package:flutter/widgets.dart';
import 'package:tax_invoice_new/features/resources/custom_color.dart';

class CustomTextStyle {
  CustomTextStyle._();

  static const String fontFamily = 'Nunito';

  static TextStyle heading48Normal = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.normal,
    color: CustomColor.contrastBlackColor,
    height: 1.5,
    letterSpacing: .2,
    wordSpacing: 1.5,
  );

  static TextStyle heading36Normal = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.normal,
    color: CustomColor.contrastBlackColor,
    height: 1.5,
    letterSpacing: .2,
    wordSpacing: 1.5,
  );

  static TextStyle heading24Bold = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: CustomColor.contrastBlackColor,
    height: 1.5,
    letterSpacing: .2,
    wordSpacing: 1.5,
  );

  static TextStyle heading18 = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: CustomColor.contrastBlackColor,
    height: 1.5,
    letterSpacing: .2,
    wordSpacing: 1.5,
  );

  static TextStyle heading18Normal = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: CustomColor.contrastBlackColor,
    height: 1.5,
    letterSpacing: .2,
    wordSpacing: 1.5,
  );
  static TextStyle heading16 = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: CustomColor.contrastBlackColor,
    height: 1.5,
    letterSpacing: .2,
    wordSpacing: 1.5,
  );
  static TextStyle heading16Normal = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    color: CustomColor.contrastBlackColor,
    height: 1.5,
    letterSpacing: .2,
    wordSpacing: 1.5,
  );
  static const TextStyle heading14 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    color: CustomColor.contrastBlackColor,
    height: 1.5,
    letterSpacing: .2,
    wordSpacing: 1.5,
  );
  static TextStyle heading14Bold = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: CustomColor.contrastBlackColor,
    height: 1.5,
    letterSpacing: .2,
    wordSpacing: 1.5,
  );
  static const TextStyle heading12 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    color: CustomColor.contrastBlackColor,
    height: 1.5,
    letterSpacing: .2,
    wordSpacing: 1.5,
  );
  static const TextStyle heading12Bold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 12,
    color: CustomColor.contrastBlackColor,
    height: 1.5,
    letterSpacing: .2,
    wordSpacing: 1.5,
  );
  static const TextStyle heading10 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    color: CustomColor.contrastBlackColor,
    height: 1.5,
    letterSpacing: .2,
    wordSpacing: 1.5,
  );
  static TextStyle heading8 = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 8,
    color: CustomColor.contrastBlackColor,
    height: 1.5,
    letterSpacing: .2,
    wordSpacing: 1.5,
  );
  static TextStyle heading10Bold = const TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 10,
    color: CustomColor.contrastBlackColor,
    height: 1.5,
    letterSpacing: .2,
    wordSpacing: 1.5,
  );
  static TextStyle errorHeading10 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    color: CustomColor.errorColor,
    height: 1.5,
    letterSpacing: .2,
    wordSpacing: 1.5,
  );
}
