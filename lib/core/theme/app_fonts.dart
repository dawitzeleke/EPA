import 'package:flutter/material.dart';

class AppFonts {
  // Font families
  static const String primaryFont = 'Montserrat';
  static const String secondaryFont = 'InriaSans';

  // Font sizes
  static const double headline1 = 32.0;
  static const double headline2 = 28.0;
  static const double headline3 = 24.0;
  static const double headline4 = 20.0;
  static const double headline5 = 18.0;
  static const double headline6 = 16.0;
  static const double bodyText1 = 16.0;
  static const double bodyText2 = 14.0;
  static const double caption = 12.0;
  static const double overline = 10.0;

  // Font weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Text styles
  static TextStyle headline1Style = const TextStyle(
    fontFamily: primaryFont,
    fontSize: headline1,
    fontWeight: bold,
    color: Colors.black,
  );

  static TextStyle headline2Style = const TextStyle(
    fontFamily: primaryFont,
    fontSize: headline2,
    fontWeight: semiBold,
    color: Colors.black,
  );

  static TextStyle bodyText1Style = const TextStyle(
    fontFamily: primaryFont,
    fontSize: bodyText1,
    fontWeight: regular,
    color: Colors.black87,
  );

  static TextStyle bodyText2Style = const TextStyle(
    fontFamily: primaryFont,
    fontSize: bodyText2,
    fontWeight: regular,
    color: Colors.black54,
  );

  static TextStyle headline3Style = const TextStyle(
    fontFamily: primaryFont,
    fontSize: headline3,
    fontWeight: medium,
    color: Colors.black,
  );

  static TextStyle headline4Style = const TextStyle(
    fontFamily: primaryFont,
    fontSize: headline4,
    fontWeight: regular,
    color: Colors.black,
  );

  static TextStyle headline5Style = const TextStyle(
    fontFamily: primaryFont,
    fontSize: headline5,
    fontWeight: regular,
    color: Colors.black,
  );

  static TextStyle headline6Style = const TextStyle(
    fontFamily: primaryFont,
    fontSize: headline6,
    fontWeight: medium,
    color: Colors.black,
  );

  static TextStyle captionStyle = const TextStyle(
    fontFamily: primaryFont,
    fontSize: caption,
    fontWeight: regular,
    color: Colors.black38,
  );

  static TextStyle overlineStyle = const TextStyle(
    fontFamily: primaryFont,
    fontSize: overline,
    fontWeight: regular,
    color: Colors.black38,
  );
}