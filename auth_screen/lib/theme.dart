// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF003D5B); // Dark Blue
const Color secondaryColor = Color(0xFF3A5A40); // Dark Green
const Color backgroundColor = Color(0xFFEBF1F5); // Light Background
const Color buttonColor = Color(0xFF3A5A40); // Dark Green

final ThemeData appTheme = ThemeData(
  primaryColor: primaryColor,
  scaffoldBackgroundColor: backgroundColor,
  appBarTheme: const AppBarTheme(
    color: primaryColor,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  textTheme: TextTheme(
    headline1: const TextStyle(
      color: primaryColor,
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    bodyText1: const TextStyle(
      color: secondaryColor,
      fontSize: 16,
    ),
    titleMedium: const TextStyle(
      color: secondaryColor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: buttonColor,
    textTheme: ButtonTextTheme.primary,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: secondaryColor,
  ),
);
