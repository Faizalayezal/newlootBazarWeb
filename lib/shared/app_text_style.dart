import 'package:flutter/material.dart';

class AppTextStyle {

  static const String font = "AppFont";

  static TextStyle light({
    double size = 14,
    Color color = Colors.black,
    double? height,
  }) {
    return TextStyle(
      fontFamily: font,
      fontWeight: FontWeight.w300,
      fontSize: size,
      color: color,
      height: height,
    );
  }

  static TextStyle regular({
    double size = 14,
    Color color = Colors.black,
    double? height,
  }) {
    return TextStyle(
      fontFamily: font,
      fontWeight: FontWeight.w400,
      fontSize: size,
      color: color,
      height: height,
    );
  }

  static TextStyle medium({
    double size = 14,
    Color color = Colors.black,
    double? height,
  }) {
    return TextStyle(
      fontFamily: font,
      fontWeight: FontWeight.w500,
      fontSize: size,
      color: color,
      height: height,
    );
  }

  static TextStyle semiBold({
    double size = 14,
    Color color = Colors.black,
    double? height,
  }) {
    return TextStyle(
      fontFamily: font,
      fontWeight: FontWeight.w600,
      fontSize: size,
      color: color,
      height: height,
    );
  }

  static TextStyle bold({
    double size = 14,
    Color color = Colors.black,
    double? height,
  }) {
    return TextStyle(
      fontFamily: font,
      fontWeight: FontWeight.w700,
      fontSize: size,
      color: color,
      height: height,
    );
  }

  static TextStyle italic({
    double size = 14,
    Color color = Colors.black,
    double? height,
  }) {
    return TextStyle(
      fontFamily: font,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.italic,
      fontSize: size,
      color: color,
      height: height,
    );
  }
}