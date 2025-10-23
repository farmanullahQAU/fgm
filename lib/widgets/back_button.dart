import 'package:flutter/material.dart';
import 'package:fmac/core/values/app_colors.dart';
import 'package:get/get.dart';

class BackButtonIos extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final double size;
  final EdgeInsetsGeometry? padding;

  const BackButtonIos({
    super.key,
    this.onPressed,
    this.color,
    this.size = 24,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Get.theme.brightness == Brightness.dark;
    final buttonColor =
        color ?? (isDark ? AppColors.darkIconColor : AppColors.lightIconColor);

    return Center(
      child: Container(
        child: Padding(
          padding: padding ?? const EdgeInsets.only(left: 8),
          child: InkWell(
            onTap: onPressed ?? () => Get.back(),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.surfaceContainer,

                shape: BoxShape.circle,
              ),

              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: Icon(Icons.chevron_left, size: size, color: buttonColor),
            ),
          ),
        ),
      ),
    );
  }
}
