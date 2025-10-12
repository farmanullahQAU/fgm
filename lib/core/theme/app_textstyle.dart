import 'package:flutter/material.dart';
import 'package:fmac/core/values/app_colors.dart';

class AppTextStyles {
  // Helper method to get theme-aware color
  static Color _getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black87;
  }

  static Color _getAccentColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.white
        : AppColors.black;
  }

  // Font size 10
  static TextStyle size10Regular(BuildContext context) => TextStyle(
    fontFamily: 'HKGrotesk',
    fontWeight: FontWeight.w400, // Regular
    fontSize: 10,
    color: _getTextColor(context),
  );

  static TextStyle size10Medium(BuildContext context) => TextStyle(
    fontFamily: 'HKGrotesk',
    fontWeight: FontWeight.w500, // Medium
    fontSize: 10,
    color: _getAccentColor(context),
  );

  static TextStyle size10Bold(BuildContext context) => TextStyle(
    fontFamily: 'HKGrotesk',
    fontWeight: FontWeight.w700, // Bold
    fontSize: 10,
    color: _getTextColor(context),
  );

  // Font size 12
  static TextStyle size12Regular(BuildContext context) => TextStyle(
    fontFamily: 'HKGrotesk',
    fontWeight: FontWeight.w400, // Regular
    fontSize: 12,
    color: _getTextColor(context),
  );

  static TextStyle size12Medium(BuildContext context) => TextStyle(
    fontFamily: 'HKGrotesk',
    fontWeight: FontWeight.w500, // Medium
    fontSize: 12,
    color: _getAccentColor(context),
  );

  static TextStyle size12Bold(BuildContext context) => TextStyle(
    fontFamily: 'HKGrotesk',
    fontWeight: FontWeight.w700, // Bold
    fontSize: 12,
    color: _getTextColor(context),
  );

  // Add more (e.g., size 14)
  static TextStyle size14Regular(BuildContext context) => TextStyle(
    fontFamily: 'HKGrotesk',
    fontWeight: FontWeight.w400, // Regular
    fontSize: 14,
    color: _getTextColor(context),
  );

  static TextStyle size14Bold(BuildContext context) => TextStyle(
    fontFamily: 'HKGrotesk',
    fontWeight: FontWeight.w700, // Bold
    fontSize: 14,
    color: _getTextColor(context),
  );
}
