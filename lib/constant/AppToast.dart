import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppToast {
  AppToast._();

  static void show(
      String message, {
        ToastGravity gravity = ToastGravity.BOTTOM,
        Color backgroundColor = Colors.black87,
        Color textColor = Colors.white,
        double fontSize = 14,
        Toast length = Toast.LENGTH_SHORT,
      }) {
    Fluttertoast.cancel();

    Fluttertoast.showToast(
      msg: message,
      toastLength: length,
      gravity: gravity,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: fontSize,
    );
  }

  static void success(String message) {
    show(
      message,
      backgroundColor: Colors.green,
    );
  }

  static void error(String message) {
    show(
      message,
      backgroundColor: Colors.red,
    );
  }

  static void warning(String message) {
    show(
      message,
      backgroundColor: Colors.orange,
    );
  }

  static void info(String message) {
    show(
      message,
      backgroundColor: Colors.blue,
    );
  }
}